<?php

namespace App\Filament\Widgets;

use App\Models\CashFundContribution;
use App\Models\Guest;
use App\Models\User;
use App\Models\Wedding;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $revenue = CashFundContribution::where('status', 'paid')->sum('amount');

        return [
            Stat::make('Weddings', Wedding::count())
                ->description(Wedding::where('status', 'live')->count() . ' live now')
                ->descriptionIcon('heroicon-m-signal')
                ->color('primary'),

            Stat::make('Users', User::count())
                ->description('Registered couples')
                ->descriptionIcon('heroicon-m-users')
                ->color('info'),

            Stat::make('Guests attending', Guest::where('rsvp_status', 'attending')->count())
                ->description('of ' . Guest::count() . ' total guests')
                ->descriptionIcon('heroicon-m-heart')
                ->color('success'),

            Stat::make('Contribution revenue', '$' . number_format($revenue, 2))
                ->description(CashFundContribution::where('status', 'paid')->count() . ' paid contributions')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('warning'),
        ];
    }
}
