<?php

namespace App\Services;

use Carbon\Carbon;
use Carbon\CarbonInterface;
use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Http;

/**
 * Verifies native in-app purchases against Apple's and Google's real,
 * documented server APIs. No purchase is ever trusted on the client's
 * word alone — every grant goes through here first.
 *
 * Two products exist: the one-time Wedding Pass ("pass") and the monthly
 * Udo Premium subscription ("premium").
 */
class PurchaseVerificationService
{
    public function isAppleConfigured(): bool
    {
        return filled(config('services.apple_iap.shared_secret')) && filled(config('services.apple_iap.product_id'));
    }

    public function isGoogleConfigured(): bool
    {
        return filled(config('services.google_play.service_account_json'))
            && filled(config('services.google_play.package_name'))
            && filled(config('services.google_play.product_id'));
    }

    /**
     * @return array{valid: bool, transaction_id: ?string, kind: ?string, expires_at: ?CarbonInterface, error: ?string}
     */
    public function verifyApple(string $receiptData, ?string $productId = null): array
    {
        $productId ??= config('services.apple_iap.product_id');
        $isPremium = $productId === config('services.apple_iap.premium_product_id');

        if (! $isPremium && $productId !== config('services.apple_iap.product_id')) {
            return $this->failure('Unexpected product id.');
        }

        $payload = [
            'receipt-data' => $receiptData,
            'password' => config('services.apple_iap.shared_secret'),
            'exclude-old-transactions' => true,
        ];

        $body = Http::post('https://buy.itunes.apple.com/verifyReceipt', $payload)->json() ?? [];

        // Apple's documented behaviour: a sandbox receipt sent to the
        // production endpoint returns status 21007 — retry against sandbox.
        if (($body['status'] ?? null) === 21007) {
            $body = Http::post('https://sandbox.itunes.apple.com/verifyReceipt', $payload)->json() ?? [];
        }

        if (($body['status'] ?? -1) !== 0) {
            return $this->failure('Apple rejected this receipt (status ' . ($body['status'] ?? 'unknown') . ').');
        }

        $purchases = $body['latest_receipt_info'] ?? $body['receipt']['in_app'] ?? [];
        $match = collect($purchases)
            ->where('product_id', $productId)
            ->sortByDesc(fn ($p) => (int) ($p['expires_date_ms'] ?? $p['purchase_date_ms'] ?? 0))
            ->first();

        if (! $match) {
            return $this->failure('This receipt does not contain the expected product.');
        }

        if (! $isPremium) {
            return ['valid' => true, 'transaction_id' => $match['transaction_id'], 'kind' => 'pass', 'expires_at' => null, 'error' => null];
        }

        $expiresAt = isset($match['expires_date_ms']) ? Carbon::createFromTimestampMs((int) $match['expires_date_ms']) : null;
        if (! $expiresAt || $expiresAt->isPast()) {
            return $this->failure('This subscription has expired.');
        }

        return [
            'valid' => true,
            'transaction_id' => $match['original_transaction_id'] ?? $match['transaction_id'],
            'kind' => 'premium',
            'expires_at' => $expiresAt,
            'error' => null,
        ];
    }

    /**
     * @return array{valid: bool, transaction_id: ?string, kind: ?string, expires_at: ?CarbonInterface, error: ?string}
     */
    public function verifyGoogle(string $purchaseToken, string $productId): array
    {
        $isPremium = $productId === config('services.google_play.premium_product_id');
        if (! $isPremium && $productId !== config('services.google_play.product_id')) {
            return $this->failure('Unexpected product id.');
        }

        if ($isPremium) {
            $state = $this->googleSubscriptionState($purchaseToken);

            if (! $state) {
                return $this->failure('Google Play could not verify this subscription.');
            }

            return [
                ...$state,
                'kind' => 'premium',
                'error' => $state['valid'] ? null : 'This subscription is not active.',
            ];
        }

        $accessToken = $this->googleAccessToken();
        if (! $accessToken) {
            return $this->failure('Could not authenticate with Google Play.');
        }

        $packageName = config('services.google_play.package_name');
        $url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{$packageName}/purchases/products/{$productId}/tokens/{$purchaseToken}";

        $response = Http::withToken($accessToken)->get($url);
        if (! $response->successful()) {
            return $this->failure('Google Play could not verify this purchase.');
        }

        $body = $response->json() ?? [];
        if ((int) ($body['purchaseState'] ?? 1) !== 0) {
            return $this->failure('This purchase is not in a completed state.');
        }

        return ['valid' => true, 'transaction_id' => $body['orderId'] ?? $purchaseToken, 'kind' => 'pass', 'expires_at' => null, 'error' => null];
    }

    /**
     * Current state of a Google Play subscription (Play Developer API,
     * subscriptionsv2). "Valid" means the user should have access right now:
     * active, in a billing grace period, or cancelled but not yet expired.
     *
     * @return array{valid: bool, transaction_id: ?string, expires_at: ?CarbonInterface}|null  null when Google can't be reached
     */
    public function googleSubscriptionState(string $purchaseToken): ?array
    {
        $accessToken = $this->googleAccessToken();
        if (! $accessToken) {
            return null;
        }

        $packageName = config('services.google_play.package_name');
        $response = Http::withToken($accessToken)->get(
            "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{$packageName}/purchases/subscriptionsv2/tokens/{$purchaseToken}"
        );

        if (! $response->successful()) {
            return null;
        }

        $body = $response->json() ?? [];
        $expiry = $body['lineItems'][0]['expiryTime'] ?? null;
        $expiresAt = $expiry ? Carbon::parse($expiry) : null;
        $liveStates = ['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD', 'SUBSCRIPTION_STATE_CANCELED'];

        return [
            'valid' => in_array($body['subscriptionState'] ?? '', $liveStates, true) && $expiresAt !== null && $expiresAt->isFuture(),
            'transaction_id' => $body['latestOrderId'] ?? $purchaseToken,
            'expires_at' => $expiresAt,
        ];
    }

    private function failure(string $error): array
    {
        return ['valid' => false, 'transaction_id' => null, 'kind' => null, 'expires_at' => null, 'error' => $error];
    }

    private function googleAccessToken(): ?string
    {
        $jsonPath = config('services.google_play.service_account_json');
        if (! $jsonPath || ! is_file($jsonPath)) {
            return null;
        }

        $account = json_decode((string) file_get_contents($jsonPath), true);
        if (! is_array($account) || empty($account['client_email']) || empty($account['private_key'])) {
            return null;
        }

        $now = time();
        $jwt = JWT::encode([
            'iss' => $account['client_email'],
            'scope' => 'https://www.googleapis.com/auth/androidpublisher',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ], $account['private_key'], 'RS256');

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]);

        return $response->successful() ? $response->json('access_token') : null;
    }
}
