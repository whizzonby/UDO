<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Support\ServiceProvider;
use Laravel\Socialite\Contracts\Factory as SocialiteFactory;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // Register Apple Socialite driver directly — socialiteproviders/manager
        // is not auto-discovered in this project, so we bypass its event system.
        $this->callAfterResolving(SocialiteFactory::class, function ($socialite) {
            $socialite->extend('apple', function () use ($socialite) {
                return $socialite->buildProvider(
                    \SocialiteProviders\Apple\Provider::class,
                    config('services.apple')
                );
            });
        });

        // This is an API-only app with no `password.reset` web route, so the
        // default notification (which calls route('password.reset', ...))
        // would 500. Point it at the Next.js guest/admin web app instead.
        ResetPassword::createUrlUsing(function ($notifiable, string $token) {
            $frontendUrl = rtrim(env('FRONTEND_URL', 'http://localhost:3000'), '/');
            return "{$frontendUrl}/reset-password?token={$token}&email=" . urlencode($notifiable->getEmailForPasswordReset());
        });
    }
}
