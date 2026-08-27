<?php

namespace App\Http\Controllers;

use App\Models\Wedding;
use App\Models\Subscription;
use App\Services\PurchaseVerificationService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class BillingController extends Controller
{
    /**
     * Whether native in-app purchases are wired up on the server, per
     * platform. The mobile paywall calls this on load so it can show an
     * honest "payments are being set up" state instead of a confusing
     * store error while App Store Connect / Play Console configuration is
     * still in progress.
     */
    public function config(PurchaseVerificationService $verifier): JsonResponse
    {
        return response()->json([
            'data' => [
                'ios_configured' => $verifier->isAppleConfigured(),
                'android_configured' => $verifier->isGoogleConfigured(),
                'lifetime_product_id' => [
                    'ios' => config('services.apple_iap.product_id'),
                    'android' => config('services.google_play.product_id'),
                ],
            ],
        ]);
    }

    public function entitlements(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding instanceof Wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return response()->json([
            'data' => app(SubscriptionEntitlementService::class)->payloadFor($wedding),
        ]);
    }

    public function plans(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding instanceof Wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return response()->json([
            'data' => app(SubscriptionEntitlementService::class)->planCatalogFor($wedding),
        ]);
    }

    public function changePlan(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding instanceof Wedding, 404, 'No wedding found.');
        abort_unless($wedding->owner_user_id === $request->user()->id, 403, 'Only the wedding owner can change plans.');

        $data = $request->validate([
            'plan' => ['required', 'string', Rule::in(SubscriptionEntitlementService::SELF_SERVICE_PLANS)],
            'billing_cycle' => 'nullable|string|in:monthly,annual',
            'confirm' => 'accepted',
        ]);

        $service = app(SubscriptionEntitlementService::class);
        $definition = SubscriptionEntitlementService::PLANS[$data['plan']];
        $usage = $service->payloadFor($wedding)['usage'];

        abort_unless(
            $service->usageFitsPlan($usage, $definition['limits']),
            422,
            'Current workspace usage is above this plan limit. Reduce usage or choose a higher plan.'
        );

        $billingCycle = $data['billing_cycle'] ?? 'monthly';
        $subscription = $request->user()->subscriptions()->latest()->first() ?? new Subscription(['user_id' => $request->user()->id]);
        $subscription->fill([
            'plan' => $data['plan'],
            'status' => 'active',
            'billing_cycle' => $billingCycle,
            'amount' => $billingCycle === 'annual' ? $definition['annual_price'] : $definition['monthly_price'],
            'currency' => 'USD',
            'current_period_start' => now(),
            'current_period_end' => $billingCycle === 'annual' ? now()->addYear() : now()->addMonth(),
            'metadata' => [
                ...($subscription->metadata ?? []),
                'last_customer_change' => [
                    'plan' => $data['plan'],
                    'billing_cycle' => $billingCycle,
                    'at' => now()->toISOString(),
                    'stripe_price_id' => config("services.billing.stripe_prices.{$data['plan']}.{$billingCycle}"),
                ],
            ],
        ]);
        $subscription->save();

        return response()->json([
            'data' => $service->payloadFor($wedding),
            'message' => 'Plan updated.',
        ]);
    }
}
