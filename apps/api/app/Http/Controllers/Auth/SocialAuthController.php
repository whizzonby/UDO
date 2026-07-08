<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialAuthController extends Controller
{
    private array $allowedProviders = ['google', 'apple'];

    public function redirect(string $provider): RedirectResponse
    {
        abort_unless(in_array($provider, $this->allowedProviders), 404);

        return Socialite::driver($provider)->stateless()->redirect();
    }

    public function callback(string $provider)
    {
        abort_unless(in_array($provider, $this->allowedProviders), 404);

        $socialUser = Socialite::driver($provider)->stateless()->user();

        $user = User::updateOrCreate(
            ['email' => $socialUser->getEmail()],
            [
                'name'             => $socialUser->getName() ?? $socialUser->getEmail(),
                'first_name'       => $this->extractFirstName($socialUser->getName()),
                'last_name'        => $this->extractLastName($socialUser->getName()),
                'avatar_url'       => $socialUser->getAvatar(),
                'auth_provider'    => $provider,
                'auth_provider_id' => $socialUser->getId(),
                'password'         => Hash::make(Str::random(32)),
            ]
        );

        $user->tokens()->where('name', 'api')->delete();
        $token = $user->createToken('api')->plainTextToken;

        $frontendUrl = config('app.frontend_url', env('FRONTEND_URL', 'http://localhost:3000'));

        return redirect("{$frontendUrl}/auth/callback?token={$token}&onboarding={$user->onboarding_completed}");
    }

    private function extractFirstName(?string $name): string
    {
        if (! $name) return '';
        $parts = explode(' ', $name, 2);
        return $parts[0];
    }

    private function extractLastName(?string $name): string
    {
        if (! $name) return '';
        $parts = explode(' ', $name, 2);
        return $parts[1] ?? '';
    }
}
