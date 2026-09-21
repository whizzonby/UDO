<?php

namespace App\Console\Commands;

use App\Models\Subscription;
use App\Services\PurchaseVerificationService;
use Illuminate\Console\Command;

class SyncPlaySubscriptionsCommand extends Command
{
    protected $signature = 'billing:sync-play-subscriptions';

    protected $description = 'Refresh Udo Premium subscriptions bought through Google Play (renewals, cancellations, expiries) from the Play Developer API.';

    public function handle(PurchaseVerificationService $verifier): int
    {
        if (! $verifier->isGoogleConfigured()) {
            $this->warn('Google Play is not configured; nothing to sync.');
            return self::SUCCESS;
        }

        $synced = 0;

        Subscription::where('plan', 'premium')
            ->where('platform', 'android')
            ->whereIn('status', ['active', 'trialing'])
            // Only those at or near their period end — renewals land here.
            ->where('current_period_end', '<', now()->addDay())
            ->each(function (Subscription $subscription) use ($verifier, &$synced) {
                $token = $subscription->metadata['play_purchase_token'] ?? null;
                if (! $token) {
                    return;
                }

                $state = $verifier->googleSubscriptionState($token);
                if (! $state) {
                    return; // Google unreachable — try again next run, don't revoke access.
                }

                if ($state['valid']) {
                    $subscription->update(['current_period_end' => $state['expires_at']]);
                } else {
                    $subscription->update(['status' => 'expired', 'ends_at' => now()]);
                }

                $synced++;
            });

        $this->info("Synced {$synced} Play subscription(s).");

        return self::SUCCESS;
    }
}
