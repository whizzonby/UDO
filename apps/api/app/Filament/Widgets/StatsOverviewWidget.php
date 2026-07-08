<?php

namespace App\Filament\Widgets;

use App\Models\Guest;
use App\Models\RegistryContribution;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Wedding;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $totalRevenue = RegistryContribution::where('payment_status', 'succeeded')->sum('amount');
        $mrrBase = Subscription::where('status', 'active')
            ->where('plan', '!=', 'free')
            ->sum('amount');

        $activeWeddingsThisMonth = Wedding::whereMonth('event_date', now()->month)
            ->whereYear('event_date', now()->year)
            ->count();

        $newUsersThisMonth = User::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        return [
            Stat::make('Total weddings', Wedding::count())
                ->description(Wedding::where('status', 'planning')->count() . ' planning · ' . Wedding::where('status', 'live')->count() . ' live')
                ->color('success')
                ->icon('heroicon-o-calendar-days'),

            Stat::make('Total users', User::count())
                ->description('+' . $newUsersThisMonth . ' this month')
                ->color('info')
                ->icon('heroicon-o-users'),

            Stat::make('Total guests', Guest::count())
                ->description(Guest::where('attending_status', 'yes')->count() . ' confirmed')
                ->color('warning')
                ->icon('heroicon-o-user-group'),

            Stat::make('Registry revenue', '$' . number_format($totalRevenue, 0))
                ->description('All-time contributions')
                ->color('success')
                ->icon('heroicon-o-banknotes'),

            Stat::make('Active pro subscriptions', Subscription::where('status', 'active')->where('plan', '!=', 'free')->count())
                ->description('$' . number_format($mrrBase, 0) . ' MRR')
                ->color('primary')
                ->icon('heroicon-o-star'),

            Stat::make('Weddings this month', $activeWeddingsThisMonth)
                ->description(Wedding::where('status', 'post_wedding')->count() . ' completed all-time')
                ->color('danger')
                ->icon('heroicon-o-heart'),
        ];
    }
}
