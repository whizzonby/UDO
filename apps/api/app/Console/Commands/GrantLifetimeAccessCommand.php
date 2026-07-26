<?php

namespace App\Console\Commands;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Console\Command;

class GrantLifetimeAccessCommand extends Command
{
    protected $signature = 'users:grant-lifetime
        {email : Email address of the user to grant lifetime access}';

    protected $description = 'Grant a user lifetime access without a real payment (testing/review accounts). Skips the purchase receipt email that a real Stripe/IAP purchase sends.';

    public function handle(): int
    {
        $email = strtolower(trim((string) $this->argument('email')));
        $user = User::where('email', $email)->first();

        if (! $user) {
            $this->error("No user found with email [{$email}].");
            return self::FAILURE;
        }

        $subscription = $user->subscriptions()->latest()->first() ?? new Subscription(['user_id' => $user->id]);
        $subscription->fill([
            'plan' => 'lifetime',
            'status' => 'active',
            'billing_cycle' => 'one_time',
            'amount' => 0,
            'currency' => 'USD',
            'current_period_start' => now(),
            'current_period_end' => null,
            'ends_at' => null,
            'platform' => 'manual_grant',
            'platform_transaction_id' => 'manual-' . now()->timestamp,
            'metadata' => [
                ...($subscription->metadata ?? []),
                'lifetime_granted_manually_at' => now()->toISOString(),
                'granted_via' => 'users:grant-lifetime',
            ],
        ]);
        $subscription->save();

        $this->info("Granted lifetime access to {$email} (no payment, no receipt email sent).");

        return self::SUCCESS;
    }
}
