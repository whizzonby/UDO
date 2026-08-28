<?php

namespace App\Filament\Widgets;

use App\Models\StoreLinkClick;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StoreClicksStatsWidget extends BaseWidget
{
    protected ?string $heading = 'App link clicks';

    protected function getStats(): array
    {
        $today = StoreLinkClick::whereDate('created_at', now()->toDateString())->count();
        $last7 = StoreLinkClick::where('created_at', '>=', now()->subDays(7))->count();
        $last30 = StoreLinkClick::where('created_at', '>=', now()->subDays(30))->count();
        $prev7 = StoreLinkClick::whereBetween('created_at', [now()->subDays(14), now()->subDays(7)])->count();

        $spark = collect(range(6, 0))->map(function (int $daysAgo) {
            $day = now()->subDays($daysAgo);

            return StoreLinkClick::whereDate('created_at', $day->toDateString())->count();
        })->all();

        $delta = $prev7 === 0
            ? ($last7 > 0 ? '+new' : 'no change')
            : sprintf('%+d%% vs prior 7d', (int) round((($last7 - $prev7) / $prev7) * 100));

        $topSource = StoreLinkClick::where('created_at', '>=', now()->subDays(30))
            ->whereNotNull('utm_source')
            ->selectRaw('utm_source, count(*) as c')
            ->groupBy('utm_source')
            ->orderByDesc('c')
            ->first();

        return [
            Stat::make('Clicks today', $today)
                ->icon('heroicon-o-cursor-arrow-ripple')
                ->color('primary'),

            Stat::make('Last 7 days', $last7)
                ->description($delta)
                ->descriptionColor(str_starts_with($delta, '-') ? 'danger' : 'success')
                ->chart($spark)
                ->color('success'),

            Stat::make('Last 30 days', $last30)
                ->description($topSource ? "Top source: {$topSource->utm_source} ({$topSource->c})" : 'No UTM-tagged traffic yet')
                ->color('gray'),
        ];
    }
}
