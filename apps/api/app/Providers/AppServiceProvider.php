<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void {}

    public function boot(): void
    {
        JsonResource::withoutWrapping();

        // Register /broadcasting/auth with Sanctum so mobile clients can auth private channels.
        Broadcast::routes(['middleware' => ['auth:sanctum']]);
        require base_path('routes/channels.php');

        // Point Laravel's password reset emails at the Next.js reset page
        // instead of the default Blade web view (which doesn't exist in API mode).
        ResetPassword::createUrlUsing(function (object $notifiable, string $token): string {
            $base = rtrim(config('app.guest_web_url', 'https://udo.app'), '/');
            return $base . '/reset-password?token=' . $token
                . '&email=' . urlencode($notifiable->getEmailForPasswordReset());
        });
    }
}

