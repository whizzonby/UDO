<?php

namespace App\Http\Controllers;

use App\Services\PurchaseVerificationService;
use App\Services\SubscriptionEntitlementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Verifies native in-app purchases (Apple StoreKit / Google Play Billing)
 * for users who bought lifetime access directly from a store, not via the
 * website's Stripe checkout. No purchase unlocks anything until Apple's or
 * Google's own servers have confirmed it — see PurchaseVerificationService.
 */
class IapController extends Controller
{
    public function verifyPurchase(Request $request): JsonResponse
    {
        $data = $request->validate([
            'platform' => 'required|string|in:ios,android',
            'product_id' => 'required|string',
            'receipt_data' => 'required_if:platform,ios|string',
            'purchase_token' => 'required_if:platform,android|string',
        ]);

        $verifier = app(PurchaseVerificationService::class);

        if ($data['platform'] === 'ios') {
            if (! $verifier->isAppleConfigured()) {
                return response()->json(['data' => ['configured' => false]]);
            }
            $result = $verifier->verifyApple($data['receipt_data'], $data['product_id']);
        } else {
            if (! $verifier->isGoogleConfigured()) {
                return response()->json(['data' => ['configured' => false]]);
            }
            $result = $verifier->verifyGoogle($data['purchase_token'], $data['product_id']);
        }

        if (! $result['valid']) {
            return response()->json(['message' => $result['error'] ?? 'Could not verify this purchase.'], 422);
        }

        $entitlements = app(SubscriptionEntitlementService::class);

        if (($result['kind'] ?? 'pass') === 'premium') {
            $entitlements->grantPremium(
                $request->user(),
                $data['platform'],
                $result['transaction_id'] ?? $data['product_id'],
                $result['expires_at'],
                metadata: $data['platform'] === 'android' ? ['play_purchase_token' => $data['purchase_token']] : [],
            );
            $message = 'Subscription verified. Udo Premium unlocked.';
        } else {
            $entitlements->grantLifetime(
                $request->user(),
                $data['platform'],
                $result['transaction_id'] ?? $data['product_id'],
            );
            $message = 'Purchase verified. Wedding Pass unlocked.';
        }

        $wedding = $request->user()->activeWedding;

        return response()->json([
            'data' => [
                'configured' => true,
                ...($wedding ? app(SubscriptionEntitlementService::class)->payloadFor($wedding) : []),
            ],
            'message' => $message,
        ]);
    }
}
