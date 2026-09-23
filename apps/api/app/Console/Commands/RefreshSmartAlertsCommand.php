<?php

namespace App\Console\Commands;

use App\Models\Wedding;
use App\Services\SmartAlertService;
use Illuminate\Console\Command;
use Throwable;

/**
 * Regenerates smart alerts for every wedding on a schedule. Before this,
 * alerts were only (re)built when a couple opened the app's notifications
 * screen or an admin clicked "Refresh all", so the admin Smart Alerts list
 * was empty or stale for weddings nobody had opened recently.
 */
class RefreshSmartAlertsCommand extends Command
{
    protected $signature = 'smart-alerts:refresh';

    protected $description = 'Regenerates smart alerts (RSVPs, payments, logistics, guest readiness, anniversaries) for all weddings.';

    public function handle(SmartAlertService $alerts): int
    {
        $weddings = 0;
        $active = 0;
        $failed = 0;

        Wedding::query()->chunkById(100, function ($chunk) use ($alerts, &$weddings, &$active, &$failed) {
            foreach ($chunk as $wedding) {
                try {
                    $active += $alerts->refresh($wedding)->count();
                    $weddings++;
                } catch (Throwable $e) {
                    // One bad wedding must not stop alerts for everyone else.
                    $failed++;
                    report($e);
                    $this->warn("Wedding #{$wedding->id}: {$e->getMessage()}");
                }
            }
        });

        $this->info("Refreshed {$weddings} wedding(s): {$active} active alert(s)" . ($failed ? ", {$failed} failed" : '') . '.');

        return $failed ? self::FAILURE : self::SUCCESS;
    }
}
