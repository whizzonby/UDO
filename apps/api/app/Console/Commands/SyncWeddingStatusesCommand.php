<?php

namespace App\Console\Commands;

use App\Models\Wedding;
use App\Services\AuditLogService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

/**
 * Moves weddings forward through planning → final_week → live → completed
 * from their event_date, in each wedding's own timezone. The Live Command
 * Center only lists final_week / live weddings, and before this nothing set
 * those statuses except an admin clicking "Mark final week" / "Mark live".
 *
 * Only ever moves forward, so a manual "Mark live" ahead of time sticks, and
 * completed / post_wedding weddings are never touched.
 */
class SyncWeddingStatusesCommand extends Command
{
    protected $signature = 'weddings:sync-statuses {--dry-run : Report changes without saving}';

    protected $description = 'Advances wedding statuses to final week, live and completed based on the wedding date.';

    private const ORDER = ['planning' => 0, 'final_week' => 1, 'live' => 2, 'completed' => 3];

    public function handle(AuditLogService $auditLog): int
    {
        $changed = 0;

        Wedding::query()
            ->whereIn('status', ['planning', 'final_week', 'live'])
            ->whereNotNull('event_date')
            // Generous UTC window; the exact cut-offs use each wedding's timezone below.
            ->whereDate('event_date', '<=', now()->addDays(8)->toDateString())
            // get() rather than chunked each(): we update the filtered column.
            ->get()
            ->each(function (Wedding $wedding) use ($auditLog, &$changed) {
                $target = $this->targetStatus($wedding);

                if ($target === null || self::ORDER[$target] <= self::ORDER[$wedding->status]) {
                    return;
                }

                $this->line("Wedding #{$wedding->id}: {$wedding->status} → {$target}");
                $changed++;

                if ($this->option('dry-run')) {
                    return;
                }

                $before = $wedding->status;
                $wedding->forceFill(['status' => $target])->save();

                $auditLog->record(
                    'system.wedding_status_synced',
                    wedding: $wedding,
                    auditable: $wedding,
                    before: ['status' => $before],
                    after: ['status' => $target],
                );
            });

        $this->info(($this->option('dry-run') ? 'Would update' : 'Updated') . " {$changed} wedding(s).");

        return self::SUCCESS;
    }

    private function targetStatus(Wedding $wedding): ?string
    {
        $tz = $this->validTimezone($wedding->timezone);
        $today = Carbon::now($tz)->startOfDay();
        $eventDay = Carbon::parse($wedding->event_date->toDateString(), $tz)->startOfDay();
        // round(): across a DST change a calendar day is 23h/25h (0.96/1.04 days).
        $daysUntil = (int) round($today->diffInDays($eventDay, false));

        return match (true) {
            $daysUntil < 0 => 'completed',
            $daysUntil === 0 => 'live',
            $daysUntil <= 7 => 'final_week',
            default => null,
        };
    }

    private function validTimezone(?string $tz): string
    {
        return $tz && in_array($tz, timezone_identifiers_list(), true) ? $tz : 'UTC';
    }
}
