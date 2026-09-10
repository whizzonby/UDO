<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Wedding;
use App\Services\CouponService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use Stripe\Checkout\Session;
use Stripe\Exception\SignatureVerificationException;
use Stripe\StripeClient;
use Stripe\Webhook;

/**
 * A real Stripe Checkout integration for the one $45 one-time "lifetime"
 * plan — no Stripe product/price needs to exist in the Dashboard first
 * (inline price_data), and every endpoint here degrades to an honest
 * "not configured" response when STRIPE_SECRET_KEY etc. aren't set, the
 * same pattern already used for Pinterest (PinterestController).
 */
class CheckoutController extends Controller
{
    private const LIFETIME_PRICE_CENTS = 4500;

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

    public function store(Request $request, CouponService $couponService): JsonResponse
    {
        $this->wedding($request);

        if (! $this->isConfigured()) {
            return response()->json(['data' => ['configured' => false]]);
        }

        $data = $request->validate([
            'coupon_code' => 'nullable|string|max:40',
        ]);

        $unitAmount = self::LIFETIME_PRICE_CENTS;
        $couponCode = null;

        if (filled($data['coupon_code'] ?? null)) {
            $coupon = $couponService->findRedeemable($data['coupon_code']);

            if (! $coupon) {
                return response()->json(['message' => 'This coupon code is invalid or expired.'], 422);
            }

            if ($couponService->alreadyRedeemedBy($coupon, $request->user())) {
                return response()->json(['message' => 'This coupon has already been used on your account.'], 422);
            }

            // Stripe's payment-mode minimum charge is $0.50.
            $unitAmount = max($unitAmount - $coupon->discountCents($unitAmount), 50);
            $couponCode = $coupon->code;
        }

        $frontendUrl = rtrim((string) config('app.frontend_url'), '/');

        $session = $this->client()->checkout->sessions->create([
            'mode' => 'payment',
            'client_reference_id' => (string) $request->user()->id,
            'customer_email' => $request->user()->email,
            'metadata' => array_filter(['coupon_code' => $couponCode]),
            'line_items' => [[
                'quantity' => 1,
                'price_data' => [
                    'currency' => 'usd',
                    'unit_amount' => $unitAmount,
                    'product_data' => [
                        'name' => 'Udo Lifetime Access',
                        'description' => 'One-time payment — full access, no subscriptions.',
                    ],
                ],
            ]],
            'success_url' => "{$frontendUrl}/checkout/success?session_id={CHECKOUT_SESSION_ID}",
            'cancel_url' => "{$frontendUrl}/checkout/cancel",
        ]);

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

        if ($event->type === 'checkout.session.completed') {
            $this->handleCheckoutCompleted($event->data->object);
        }

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

        $subscription = app(SubscriptionEntitlementService::class)->grantLifetime($user, 'stripe', $session->id);
        $subscription->forceFill(['stripe_checkout_session_id' => $session->id])->save();

        $couponCode = $session->metadata['coupon_code'] ?? null;
        if ($couponCode) {
            $this->recordCouponRedemption($couponCode, $user, $session, $subscription);
        }
    }

    private function recordCouponRedemption(string $couponCode, User $user, Session $session, Subscription $subscription): void
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
            app(CouponService::class)->redeem($coupon, $user, self::LIFETIME_PRICE_CENTS, $session->id, $subscription);
        } catch (\Throwable $e) {
            report($e);
        }
    }
}
