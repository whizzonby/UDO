<?php

namespace App\Services;

use Firebase\JWT\JWT;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Server-side half of Sign in with Apple for the native app: trades the
 * one-time authorization code for a refresh token, and revokes that token
 * when the account is deleted (required by App Review guideline 5.1.1(v)).
 *
 * Every call is best-effort — Apple being unreachable or this not being
 * configured must never block a sign-in or an account deletion.
 */
class AppleSignInService
{
    public function isConfigured(): bool
    {
        return filled(config('services.apple.bundle_id'))
            && filled(config('services.apple.team_id'))
            && filled(config('services.apple.key_id'))
            && filled(config('services.apple.private_key'));
    }

    public function refreshTokenFor(string $authorizationCode): ?string
    {
        if (! $this->isConfigured()) {
            return null;
        }

        try {
            $response = Http::asForm()->timeout(8)->post('https://appleid.apple.com/auth/token', [
                'client_id' => config('services.apple.bundle_id'),
                'client_secret' => $this->clientSecret(),
                'code' => $authorizationCode,
                'grant_type' => 'authorization_code',
            ]);

            if (! $response->successful()) {
                Log::warning('Apple authorization code exchange failed', ['status' => $response->status(), 'error' => $response->json('error')]);
                return null;
            }

            return $response->json('refresh_token');
        } catch (\Throwable $e) {
            report($e);
            return null;
        }
    }

    public function revoke(string $refreshToken): bool
    {
        if (! $this->isConfigured()) {
            return false;
        }

        try {
            $response = Http::asForm()->timeout(8)->post('https://appleid.apple.com/auth/revoke', [
                'client_id' => config('services.apple.bundle_id'),
                'client_secret' => $this->clientSecret(),
                'token' => $refreshToken,
                'token_type_hint' => 'refresh_token',
            ]);

            if (! $response->successful()) {
                Log::warning('Apple token revocation failed', ['status' => $response->status(), 'error' => $response->json('error')]);
            }

            return $response->successful();
        } catch (\Throwable $e) {
            report($e);
            return false;
        }
    }

    /** Short-lived ES256 JWT signed with the Sign in with Apple .p8 key. */
    private function clientSecret(): string
    {
        // .env files usually hold the key on one line with literal "\n".
        $privateKey = str_replace('\n', "\n", (string) config('services.apple.private_key'));

        return JWT::encode([
            'iss' => config('services.apple.team_id'),
            'iat' => time(),
            'exp' => time() + 300,
            'aud' => 'https://appleid.apple.com',
            'sub' => config('services.apple.bundle_id'),
        ], $privateKey, 'ES256', config('services.apple.key_id'));
    }
}
