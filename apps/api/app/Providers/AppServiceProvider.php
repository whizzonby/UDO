<?php

namespace App\Providers;

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
    }
}
