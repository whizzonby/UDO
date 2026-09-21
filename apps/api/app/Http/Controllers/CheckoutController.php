<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Wedding;
use App\Services\CouponService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use Stripe\Checkout\Session;
use Stripe\Exception\SignatureVerificationException;
use Stripe\StripeClient;
use Stripe\Webhook;

/**
 * A real Stripe Checkout integration for the two paid options — the $49.99
 * one-time Wedding Pass ("pass") and the $4.99/month Udo Premium
 * subscription ("premium"). No Stripe product/price needs to exist in the
 * Dashboard first (inline price_data), and every endpoint here degrades to an honest
 * "not configured" response when STRIPE_SECRET_KEY etc. aren't set, the
 * same pattern already used for Pinterest (PinterestController).
 */
class CheckoutController extends Controller
{
    private const LIFETIME_PRICE_CENTS = 4999;
    private const PREMIUM_PRICE_CENTS = 499;

    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function isConfigured(): bool
    {
        return filled(config('services.stripe.secret_key'));
    }

    private function client(): StripeClient
    {
        return new StripeClient(config('services.stripe.secret_key'));
    }

    private function priceCents(string $plan): int
    {
        return $plan === 'premium' ? self::PREMIUM_PRICE_CENTS : self::LIFETIME_PRICE_CENTS;
    }

    /**
     * @return array{0: ?Coupon, 1: ?JsonResponse} the coupon, or an error response
     */
    private function resolveCoupon(?string $code, Request $request, CouponService $couponService): array
    {
        if (! filled($code)) {
            return [null, null];
        }

        $coupon = $couponService->findRedeemable($code);

        if (! $coupon) {
            return [null, response()->json(['message' => 'This coupon code is invalid or expired.'], 422)];
        }

        if ($couponService->alreadyRedeemedBy($coupon, $request->user())) {
            return [null, response()->json(['message' => 'This coupon has already been used on your account.'], 422)];
        }

        return [$coupon, null];
    }

    /** Price preview so the checkout page can show the discount before redirecting to Stripe. */
    public function couponPreview(Request $request, CouponService $couponService): JsonResponse
    {
        $data = $request->validate([
            'plan' => 'required|string|in:pass,premium',
            'coupon_code' => 'required|string|max:40',
        ]);

        [$coupon, $error] = $this->resolveCoupon($data['coupon_code'], $request, $couponService);
        if ($error) {
            return $error;
        }

        $base = $this->priceCents($data['plan']);
        $discount = min($coupon->discountCents($base), $base);

        return response()->json(['data' => [
            'code' => $coupon->code,
            'plan' => $data['plan'],
            'base_cents' => $base,
            'discount_cents' => $discount,
            'total_cents' => $base - $discount,
            'applies_to' => $data['plan'] === 'premium' ? 'first month' : 'purchase',
        ]]);
    }

    public function store(Request $request, CouponService $couponService): JsonResponse
    {
        $this->wedding($request);

        if (! $this->isConfigured()) {
            return response()->json(['data' => ['configured' => false]]);
        }

        $data = $request->validate([
            'plan' => 'nullable|string|in:pass,premium',
            'coupon_code' => 'nullable|string|max:40',
        ]);

        $plan = $data['plan'] ?? 'pass';
        $baseCents = $this->priceCents($plan);

        [$coupon, $error] = $this->resolveCoupon($data['coupon_code'] ?? null, $request, $couponService);
        if ($error) {
            return $error;
        }

        $frontendUrl = rtrim((string) config('app.frontend_url'), '/');
        $params = [
            'client_reference_id' => (string) $request->user()->id,
            'customer_email' => $request->user()->email,
            'metadata' => array_filter(['plan' => $plan, 'coupon_code' => $coupon?->code]),
            'success_url' => "{$frontendUrl}/checkout/success?session_id={CHECKOUT_SESSION_ID}",
            'cancel_url' => "{$frontendUrl}/checkout/cancel",
        ];

        if ($plan === 'premium') {
            $params += [
                'mode' => 'subscription',
                'line_items' => [[
                    'quantity' => 1,
                    'price_data' => [
                        'currency' => 'usd',
                        'unit_amount' => $baseCents,
                        'recurring' => ['interval' => 'month'],
                        'product_data' => [
                            'name' => 'Udo Premium',
                            'description' => 'Full wedding-planning access. Cancel anytime.',
                        ],
                    ],
                ]],
                'subscription_data' => ['metadata' => ['user_id' => (string) $request->user()->id]],
            ];

            if ($coupon) {
                // A one-off Stripe coupon discounts the first month's invoice only.
                $stripeCoupon = $this->client()->coupons->create([
                    'amount_off' => min($coupon->discountCents($baseCents), $baseCents),
                    'currency' => 'usd',
                    'duration' => 'once',
                    'name' => $coupon->code,
                ]);
                $params['discounts'] = [['coupon' => $stripeCoupon->id]];
            }
        } else {
            // Stripe's payment-mode minimum charge is $0.50.
            $unitAmount = $coupon ? max($baseCents - $coupon->discountCents($baseCents), 50) : $baseCents;

            $params += [
                'mode' => 'payment',
                'line_items' => [[
                    'quantity' => 1,
                    'price_data' => [
                        'currency' => 'usd',
                        'unit_amount' => $unitAmount,
                        'product_data' => [
                            'name' => 'Udo Wedding Pass',
                            'description' => 'One payment. Plan all the way to "I do."',
                        ],
                    ],
                ]],
            ];
        }

        $session = $this->client()->checkout->sessions->create($params);

        return response()->json(['data' => [
            'configured' => true,
            'checkout_url' => $session->url,
        ]]);
    }

    public function show(Request $request, string $sessionId): JsonResponse
    {
        $this->wedding($request);
        abort_unless($this->isConfigured(), 422, 'Payments are not configured.');

        try {
            $session = $this->client()->checkout->sessions->retrieve($sessionId);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Could not find this checkout session.'], 404);
        }

        abort_unless($session->client_reference_id === (string) $request->user()->id, 403);

        return response()->json(['data' => [
            'payment_status' => $session->payment_status,
            'amount_total' => $session->amount_total,
            'currency' => $session->currency,
        ]]);
    }

    public function webhook(Request $request): Response
    {
        if (! $this->isConfigured()) {
            return response('Stripe not configured', 400);
        }

        try {
            $event = Webhook::constructEvent(
                $request->getContent(),
                (string) $request->header('Stripe-Signature'),
                config('services.stripe.webhook_secret'),
            );
        } catch (SignatureVerificationException|\UnexpectedValueException $e) {
            Log::warning('Stripe webhook signature verification failed.', ['error' => $e->getMessage()]);
            return response('Invalid signature', 400);
        }

        match ($event->type) {
            'checkout.session.completed' => $this->handleCheckoutCompleted($event->data->object),
            'customer.subscription.updated', 'customer.subscription.deleted' => $this->syncStripeSubscription($event->data->object->toArray()),
            default => null,
        };

        return response('OK', 200);
    }

    private function handleCheckoutCompleted(Session $session): void
    {
        $userId = $session->client_reference_id;
        $user = $userId ? User::find($userId) : null;

        if (! $user) {
            Log::warning('Stripe checkout completed for an unknown user.', ['session_id' => $session->id]);
            return;
        }

        $entitlements = app(SubscriptionEntitlementService::class);
        $plan = ($session->mode ?? 'payment') === 'subscription' ? 'premium' : 'pass';
        $paid = $session->amount_total !== null ? $session->amount_total / 100 : null;

        if ($plan === 'premium') {
            $stripeSub = $this->client()->subscriptions->retrieve($session->subscription)->toArray();

            $subscription = $entitlements->grantPremium(
                $user,
                'stripe',
                $session->id,
                $this->stripePeriodEnd($stripeSub),
                [
                    'stripe_customer_id' => $session->customer,
                    'stripe_subscription_id' => $session->subscription,
                    'stripe_checkout_session_id' => $session->id,
                ],
                amountPaid: $paid,
            );
        } else {
            // The Pass replaces a running monthly plan — stop billing for it.
            $previous = $user->subscriptions()->latest()->first();
            if ($previous?->plan === 'premium' && $previous->stripe_subscription_id) {
                try {
                    $this->client()->subscriptions->cancel($previous->stripe_subscription_id);
                } catch (\Throwable $e) {
                    report($e);
                }
            }

            $subscription = $entitlements->grantLifetime($user, 'stripe', $session->id, $paid);
            $subscription->forceFill([
                'stripe_checkout_session_id' => $session->id,
                'stripe_subscription_id' => null,
            ])->save();
        }

        $couponCode = $session->metadata['coupon_code'] ?? null;
        if ($couponCode) {
            $this->recordCouponRedemption($couponCode, $user, $session, $subscription, $plan);
        }
    }

    /** @param array<string, mixed> $stripeSub */
    private function stripePeriodEnd(array $stripeSub): ?Carbon
    {
        // Newer Stripe API versions moved the period onto the subscription item.
        $end = $stripeSub['current_period_end'] ?? $stripeSub['items']['data'][0]['current_period_end'] ?? null;

        return $end ? Carbon::createFromTimestamp($end) : null;
    }

    /** Keeps a premium subscription's status / period in step with Stripe (renewals, cancellations, failed payments). */
    private function syncStripeSubscription(array $stripeSub): void
    {
        $subscription = Subscription::where('stripe_subscription_id', $stripeSub['id'] ?? null)
            ->where('plan', 'premium')
            ->first();

        if (! $subscription) {
            return;
        }

        $periodEnd = $this->stripePeriodEnd($stripeSub);
        $status = $stripeSub['status'] ?? 'active';

        if (in_array($status, ['canceled', 'unpaid', 'incomplete_expired'], true)) {
            $subscription->update(['status' => 'cancelled', 'cancelled_at' => $subscription->cancelled_at ?? now(), 'ends_at' => now()]);
            return;
        }

        if ($status === 'past_due') {
            $subscription->update(['status' => 'past_due']);
            return;
        }

        $cancelling = (bool) ($stripeSub['cancel_at_period_end'] ?? false);

        $subscription->update([
            'status' => 'active',
            'current_period_end' => $periodEnd,
            // Cancelled-at-period-end: access continues until the period runs out.
            'cancelled_at' => $cancelling ? ($subscription->cancelled_at ?? now()) : null,
            'ends_at' => $cancelling ? $periodEnd : null,
        ]);
    }

    private function recordCouponRedemption(string $couponCode, User $user, Session $session, Subscription $subscription, string $plan): void
    {
        $coupon = Coupon::where('code', strtoupper($couponCode))->first();

        if (! $coupon) {
            Log::warning('Coupon referenced in a completed Stripe session no longer exists.', [
                'code' => $couponCode,
                'session_id' => $session->id,
            ]);
            return;
        }

        try {
            app(CouponService::class)->redeem($coupon, $user, $this->priceCents($plan), $session->id, $subscription);
        } catch (\Throwable $e) {
            report($e);
        }
    }
}
