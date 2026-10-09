<?php

namespace App\Services;

use App\Models\AiAssistantLog;
use App\Models\IdempotencyKey;
use App\Models\MoodCheckin;
use App\Models\OnboardingResponse;
use App\Models\SavedFilter;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Stripe\StripeClient;

/**
 * Self-service account deletion (DELETE /auth/me).
 *
 * Weddings the user owns are deleted outright, with everything in them. The
 * users row itself is anonymized rather than removed: tasks, messages and
 * live updates the user created on *other* people's weddings reference it
 * with cascading foreign keys, and those belong to that wedding's owner.
 * Subscription rows are kept as payment records.
 */
class AccountDeletionService
{
    public function __construct(private readonly AppleSignInService $apple)
    {
    }

    public function delete(User $user): void
    {
        $this->stopStripeBilling($user);

        if ($user->apple_refresh_token) {
            $this->apple->revoke($user->apple_refresh_token);
        }

        $weddingIds = $user->ownedWeddings()->pluck('id')->all();
        $email = $user->email;

        DB::transaction(function () use ($user, $weddingIds, $email) {
            // Collaborators who had one of these weddings open.
            User::whereIn('active_wedding_id', $weddingIds)->update(['active_wedding_id' => null]);
            // Child tables go with it via ON DELETE CASCADE.
            $user->ownedWeddings()->delete();

            $user->tokens()->delete();
            $user->collaborations()->delete();
            OnboardingResponse::where('user_id', $user->id)->delete();
            MoodCheckin::where('user_id', $user->id)->delete();
            SavedFilter::where('user_id', $user->id)->delete();
            AiAssistantLog::where('user_id', $user->id)->delete();
            IdempotencyKey::where('user_id', $user->id)->delete();
            DB::table('sessions')->where('user_id', $user->id)->delete();
            DB::table('password_reset_tokens')->where('email', $email)->delete();
            $user->syncRoles([]);

            $user->forceFill([
                'name' => 'Deleted User',
                'first_name' => 'Deleted',
                'last_name' => 'User',
                'email' => "deleted-user-{$user->id}@udo.invalid",
                'email_verified_at' => null,
                'phone' => null,
                'avatar_url' => null,
                'auth_provider' => 'deleted',
                'auth_provider_id' => null,
                'apple_refresh_token' => null,
                'active_wedding_id' => null,
                'notification_preferences' => [],
                'support_preferences' => ['account_deleted_at' => now()->toISOString()],
                'two_factor_enabled' => false,
                'two_factor_code' => null,
                'two_factor_challenge_token' => null,
                'two_factor_expires_at' => null,
                'remember_token' => null,
                'password' => Hash::make(Str::random(64)),
            ])->save();
        });

        // Every upload for a wedding lives under weddings/{id}/ on the public disk.
        foreach ($weddingIds as $weddingId) {
            try {
                Storage::disk('public')->deleteDirectory("weddings/{$weddingId}");
            } catch (\Throwable $e) {
                report($e);
            }
        }
    }

    /**
     * A web-checkout subscription would otherwise keep renewing against an
     * account nobody can sign in to. App Store / Google Play subscriptions
     * can only be cancelled by the user in their store account.
     */
    private function stopStripeBilling(User $user): void
    {
        if (blank(config('services.stripe.secret_key'))) {
            return;
        }

        $subscriptions = $user->subscriptions()
            ->whereNotNull('stripe_subscription_id')
            ->whereIn('status', ['active', 'trialing', 'past_due'])
            ->get();

        foreach ($subscriptions as $subscription) {
            try {
                (new StripeClient(config('services.stripe.secret_key')))
                    ->subscriptions->cancel($subscription->stripe_subscription_id);
            } catch (\Throwable $e) {
                report($e);
            }

            $subscription->update(['status' => 'cancelled', 'cancelled_at' => now(), 'ends_at' => now()]);
        }
    }
}
