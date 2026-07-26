<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Http;

/**
 * Verifies native in-app purchases against Apple's and Google's real,
 * documented server APIs. No purchase is ever trusted on the client's
 * word alone — every grant goes through here first.
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
     * @return array{valid: bool, transaction_id: ?string, error: ?string}
     */
    public function verifyApple(string $receiptData): array
    {
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
            return ['valid' => false, 'transaction_id' => null, 'error' => 'Apple rejected this receipt (status ' . ($body['status'] ?? 'unknown') . ').'];
        }

        $purchases = $body['latest_receipt_info'] ?? $body['receipt']['in_app'] ?? [];
        $match = collect($purchases)->firstWhere('product_id', config('services.apple_iap.product_id'));

        if (! $match) {
            return ['valid' => false, 'transaction_id' => null, 'error' => 'This receipt does not contain the expected product.'];
        }

        return ['valid' => true, 'transaction_id' => $match['transaction_id'], 'error' => null];
    }

    /**
     * @return array{valid: bool, transaction_id: ?string, error: ?string}
     */
    public function verifyGoogle(string $purchaseToken, string $productId): array
    {
        if ($productId !== config('services.google_play.product_id')) {
            return ['valid' => false, 'transaction_id' => null, 'error' => 'Unexpected product id.'];
        }

        $accessToken = $this->googleAccessToken();
        if (! $accessToken) {
            return ['valid' => false, 'transaction_id' => null, 'error' => 'Could not authenticate with Google Play.'];
        }

        $packageName = config('services.google_play.package_name');
        $url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{$packageName}/purchases/products/{$productId}/tokens/{$purchaseToken}";

        $response = Http::withToken($accessToken)->get($url);
        if (! $response->successful()) {
            return ['valid' => false, 'transaction_id' => null, 'error' => 'Google Play could not verify this purchase.'];
        }

        $body = $response->json() ?? [];
        if ((int) ($body['purchaseState'] ?? 1) !== 0) {
            return ['valid' => false, 'transaction_id' => null, 'error' => 'This purchase is not in a completed state.'];
        }

        return ['valid' => true, 'transaction_id' => $body['orderId'] ?? $purchaseToken, 'error' => null];
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
