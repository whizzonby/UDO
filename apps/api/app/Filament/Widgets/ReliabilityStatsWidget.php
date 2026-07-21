<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\FailedJobResource;
use App\Filament\Resources\GuestTokenResource;
use App\Filament\Resources\IdempotencyKeyResource;
use App\Models\FailedJob;
use App\Models\IdempotencyKey;
use App\Services\OperationalHealthService;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class ReliabilityStatsWidget extends BaseWidget
{
    protected static ?int $sort = 0;
    protected static bool $isLazy = false;

    protected function getStats(): array
    {
        $health = app(OperationalHealthService::class)->snapshot();
        $queue = $health['queue'];
        $tokens = $health['tokens'];
        $pendingJobs = DB::table('jobs')->count();
        $activeIdempotencyKeys = IdempotencyKey::where('expires_at', '>', now())->count();

        return [
            Stat::make('Platform health', ucfirst($health['status']))
                ->description('Score ' . $health['score'])
                ->color(match ($health['status']) {
                    'healthy' => 'success',
                    'watch' => 'warning',
                    default => 'danger',
                })
                ->icon('heroicon-o-signal'),

            Stat::make('Failed jobs', $queue['failed_jobs'])
                ->description('Queue: ' . $queue['connection'])
                ->color($queue['failed_jobs'] > 0 ? 'danger' : 'success')
                ->icon('heroicon-o-exclamation-triangle')
                ->url(FailedJobResource::getUrl('index')),

            Stat::make('Pending jobs', $pendingJobs)
                ->description('Currently queued, not yet processed')
                ->color('gray')
                ->icon('heroicon-o-queue-list'),

            Stat::make('Active idempotency keys', $activeIdempotencyKeys)
                ->description('Not yet expired')
                ->color('gray')
                ->icon('heroicon-o-finger-print')
                ->url(IdempotencyKeyResource::getUrl('index')),

            Stat::make('Token expiry risk', $tokens['expired_active'] + $tokens['expiring_soon'])
                ->description($tokens['expired_active'] . ' expired active, ' . $tokens['expiring_soon'] . ' expiring within 7 days')
                ->color(($tokens['expired_active'] + $tokens['expiring_soon']) > 0 ? 'warning' : 'success')
                ->icon('heroicon-o-key')
                ->url(GuestTokenResource::getUrl('index')),

            Stat::make('Cache driver', config('cache.default'))
                ->description('30s TTL on operational health snapshots')
                ->color('gray')
                ->icon('heroicon-o-circle-stack'),
        ];
    }
}
