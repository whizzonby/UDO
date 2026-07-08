<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Firebase\JWT\JWT;
use Firebase\JWT\JWK;
use Firebase\JWT\Key;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class MobileSocialAuthController extends Controller
{
    // -------------------------------------------------------------------------
    // Google
    // -------------------------------------------------------------------------

    public function google(Request $request): JsonResponse
    {
        $request->validate(['id_token' => 'required|string']);

        $payload = $this->verifyGoogleToken($request->id_token);

        if (! $payload) {
            return response()->json(['message' => 'Invalid Google token'], 401);
        }

        $user = $this->findOrCreateUser(
            provider:  'google',
            providerId: $payload['sub'],
            email:     $payload['email'] ?? null,
            firstName: $payload['given_name'] ?? '',
            lastName:  $payload['family_name'] ?? '',
            avatarUrl: $payload['picture'] ?? null,
        );

        return $this->tokenResponse($user);
    }

    private function verifyGoogleToken(string $idToken): ?array
    {
        $allowedAudiences = array_filter([
            config('services.google.client_id'),
            config('services.google.ios_client_id'),
        ]);

        $response = Http::timeout(8)->get(
            'https://oauth2.googleapis.com/tokeninfo',
            ['id_token' => $idToken]
        );

        if (! $response->successful()) {
            return null;
        }

        $data = $response->json();

        if (! isset($data['sub'], $data['aud'])) {
            return null;
        }

        if (! in_array($data['aud'], $allowedAudiences, true)) {
            Log::warning('Google token audience mismatch', ['aud' => $data['aud']]);
            return null;
        }

        if (isset($data['exp']) && (int) $data['exp'] < time()) {
            return null;
        }

        return $data;
    }

    // -------------------------------------------------------------------------
    // Apple
    // -------------------------------------------------------------------------

    public function apple(Request $request): JsonResponse
    {
        $request->validate([
            'identity_token' => 'required|string',
            'first_name'     => 'nullable|string|max:100',
            'last_name'      => 'nullable|string|max:100',
        ]);

        $payload = $this->verifyAppleToken($request->identity_token);

        if (! $payload) {
            return response()->json(['message' => 'Invalid Apple token'], 401);
        }

        $user = $this->findOrCreateUser(
            provider:   'apple',
            providerId: $payload->sub,
            email:      $payload->email ?? null,
            firstName:  $request->first_name ?? '',
            lastName:   $request->last_name ?? '',
            avatarUrl:  null,
        );

        return $this->tokenResponse($user);
    }

    private function verifyAppleToken(string $identityToken): ?object
    {
        try {
            // Fetch Apple's public keys
            $keysResponse = Http::timeout(8)->get('https://appleid.apple.com/auth/keys');

            if (! $keysResponse->successful()) {
                return null;
            }

            $jwks = $keysResponse->json();
            $keys = JWK::parseKeySet($jwks);

            $decoded = JWT::decode($identityToken, $keys);

            // Verify issuer and audience
            $allowedAudiences = array_filter([
                config('services.apple.client_id'),
            ]);

            if ($decoded->iss !== 'https://appleid.apple.com') {
                return null;
            }

            if (! in_array($decoded->aud, $allowedAudiences, true)) {
                Log::warning('Apple token audience mismatch', ['aud' => $decoded->aud]);
                return null;
            }

            if ($decoded->exp < time()) {
                return null;
            }

            return $decoded;
        } catch (\Throwable $e) {
            Log::warning('Apple token verification failed: ' . $e->getMessage());
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Shared helpers
    // -------------------------------------------------------------------------

    private function findOrCreateUser(
        string  $provider,
        string  $providerId,
        ?string $email,
        string  $firstName,
        string  $lastName,
        ?string $avatarUrl,
    ): User {
        // 1. Try matching by provider + provider ID
        $user = User::where('auth_provider', $provider)
            ->where('auth_provider_id', $providerId)
            ->first();

        if ($user) {
            return $user;
        }

        // 2. Try matching by email (account linking)
        if ($email) {
            $user = User::where('email', $email)->first();
            if ($user) {
                $user->update([
                    'auth_provider'    => $provider,
                    'auth_provider_id' => $providerId,
                    'avatar_url'       => $user->avatar_url ?? $avatarUrl,
                ]);
                return $user;
            }
        }

        // 3. Create a new user
        $stableEmail = $email ?? "{$providerId}@{$provider}.placeholder";
        $name        = trim("$firstName $lastName") ?: $stableEmail;

        return User::create([
            'email'            => $stableEmail,
            'name'             => $name,
            'first_name'       => $firstName,
            'last_name'        => $lastName,
            'avatar_url'       => $avatarUrl,
            'auth_provider'    => $provider,
            'auth_provider_id' => $providerId,
            'password'         => bcrypt(Str::random(32)),
            'onboarding_completed' => false,
        ]);
    }

    private function tokenResponse(User $user): JsonResponse
    {
        $user->tokens()->where('name', 'mobile')->delete();
        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'                   => $user->id,
                'email'                => $user->email,
                'first_name'           => $user->first_name ?? '',
                'last_name'            => $user->last_name ?? '',
                'name'                 => $user->name,
                'avatar_url'           => $user->avatar_url,
                'onboarding_completed' => (bool) $user->onboarding_completed,
                'wedding_id'           => $user->ownedWeddings()->value('id'),
            ],
        ]);
    }
}
