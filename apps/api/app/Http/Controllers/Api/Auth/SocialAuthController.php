<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Firebase\JWT\JWK;
use Firebase\JWT\JWT;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class SocialAuthController extends Controller
{
    // ── Google ────────────────────────────────────────────────────────────────

    public function google(Request $request): JsonResponse
    {
        $request->validate(['id_token' => 'required|string']);

        $tokenInfo = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if (! $tokenInfo->successful()) {
            return response()->json(['message' => 'Invalid Google token.'], 401);
        }

        $data = $tokenInfo->json();

        // Verify the token was issued for our app (allow both Android + iOS client IDs)
        $allowed = array_filter([
            config('services.google.client_id'),
            config('services.google.ios_client_id'),
        ]);
        if (! empty($allowed) && ! in_array($data['aud'] ?? null, $allowed, true)) {
            return response()->json(['message' => 'Token audience mismatch.'], 401);
        }

        $user = $this->findOrCreateSocialUser(
            provider: 'google',
            socialId: $data['sub'],
            email: $data['email'] ?? null,
            name: $data['name'] ?? null,
            avatarUrl: $data['picture'] ?? null,
        );

        return $this->buildResponse($user);
    }

    // ── Apple ─────────────────────────────────────────────────────────────────

    public function apple(Request $request): JsonResponse
    {
        $request->validate(['identity_token' => 'required|string']);

        $payload = $this->verifyAppleToken($request->identity_token);

        if ($payload === null) {
            return response()->json(['message' => 'Invalid Apple identity token.'], 401);
        }

        $user = $this->findOrCreateSocialUser(
            provider: 'apple',
            socialId: $payload['sub'],
            email: $payload['email'] ?? null,
            // Flutter only sends full_name on first sign-in; after that Apple omits it
            name: $request->input('full_name') ?: null,
        );

        return $this->buildResponse($user);
    }

    // ── Shared helpers ────────────────────────────────────────────────────────

    private function findOrCreateSocialUser(
        string $provider,
        string $socialId,
        ?string $email,
        ?string $name,
        ?string $avatarUrl = null,
    ): User {
        // 1. Exact provider+id match
        $user = User::where('social_provider', $provider)
            ->where('social_id', $socialId)
            ->first();

        if ($user) {
            // Keep avatar fresh
            if ($avatarUrl && $user->avatar_url !== $avatarUrl) {
                $user->update(['avatar_url' => $avatarUrl]);
            }
            return $user;
        }

        // 2. Email match — link existing account
        if ($email) {
            $user = User::where('email', $email)->first();
            if ($user) {
                $user->update([
                    'social_provider' => $provider,
                    'social_id'       => $socialId,
                    'avatar_url'      => $avatarUrl ?? $user->avatar_url,
                ]);
                return $user;
            }
        }

        // 3. Create new social user
        // Apple can hide email — generate a stable placeholder from the social ID
        $resolvedEmail = $email ?? Str::lower(Str::slug($socialId)) . '@privaterelay.appleid.com';

        return User::create([
            'name'            => $name ?? 'User',
            'email'           => $resolvedEmail,
            'password'        => Hash::make(Str::random(32)),
            'avatar_url'      => $avatarUrl,
            'social_provider' => $provider,
            'social_id'       => $socialId,
        ]);
    }

    private function buildResponse(User $user): JsonResponse
    {
        $user->tokens()->where('name', 'udo-admin-app')->delete();
        $token   = $user->createToken('udo-admin-app')->plainTextToken;
        $wedding = $user->weddings()->latest()->first();

        return response()->json([
            'user'    => new UserResource($user),
            'token'   => $token,
            'wedding' => $wedding?->only(['id', 'partner_one_name', 'partner_two_name', 'wedding_date', 'status']),
        ]);
    }

    private function verifyAppleToken(string $identityToken): ?array
    {
        try {
            $jwksResponse = Http::timeout(5)->get('https://appleid.apple.com/auth/keys');
            if (! $jwksResponse->successful()) {
                return null;
            }

            $keySet = JWK::parseKeySet($jwksResponse->json());
            $decoded = JWT::decode($identityToken, $keySet);
            $payload = (array) $decoded;

            if (($payload['iss'] ?? null) !== 'https://appleid.apple.com') {
                return null;
            }

            $clientId = config('services.apple.client_id');
            if ($clientId && ($payload['aud'] ?? null) !== $clientId) {
                return null;
            }

            return $payload;
        } catch (\Throwable) {
            return null;
        }
    }
}
