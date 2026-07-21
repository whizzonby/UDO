<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\MessageResource;
use App\Filament\Resources\SupportTicketResource;
use App\Filament\Resources\WeddingResource;
use App\Models\GuestToken;
use App\Models\SupportTicket;
use App\Models\Wedding;
use App\Services\OperationalHealthService;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class OperationsHealthWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $health = app(OperationalHealthService::class)->snapshot();
        $queue = $health['queue'];
        $tokens = $health['tokens'];

        $liveWeddings = Wedding::whereIn('status', ['final_week', 'live'])->count();
        $openSupport = SupportTicket::whereIn('status', ['open', 'in_progress'])->count();
        $expiringTokens = GuestToken::where('revoked', false)
            ->whereBetween('expires_at', [now(), now()->addDays(7)])
            ->count();

        return [
            Stat::make('Platform health', ucfirst($health['status']))
                ->description('Score ' . $health['score'] . ' checked ' . now()->parse($health['checked_at'])->diffForHumans())
                ->color(match ($health['status']) {
                    'healthy' => 'success',
                    'watch' => 'warning',
                    default => 'danger',
                })
                ->icon('heroicon-o-signal')
                ->url(WeddingResource::getUrl('index')),

            Stat::make('Delivery issues', $queue['failed_deliveries'] + $queue['stale_sending_messages'])
                ->description($queue['failed_deliveries'] . ' failed, ' . $queue['stale_sending_messages'] . ' stale sending')
                ->color(($queue['failed_deliveries'] + $queue['stale_sending_messages']) > 0 ? 'danger' : 'success')
                ->icon('heroicon-o-envelope')
                ->url(MessageResource::getUrl('index')),

            Stat::make('Guest token risk', $tokens['expired_active'] + $expiringTokens)
                ->description($tokens['expired_active'] . ' expired active, ' . $expiringTokens . ' expiring soon')
                ->color(($tokens['expired_active'] + $expiringTokens) > 0 ? 'warning' : 'success')
                ->icon('heroicon-o-key'),

            Stat::make('Live operations', $liveWeddings)
                ->description('Final-week or live weddings')
                ->color($liveWeddings > 0 ? 'danger' : 'info')
                ->icon('heroicon-o-bolt')
                ->url(WeddingResource::getUrl('index')),

            Stat::make('Support load', $openSupport)
                ->description('Open or in-progress tickets')
                ->color($openSupport > 0 ? 'warning' : 'success')
                ->icon('heroicon-o-lifebuoy')
                ->url(SupportTicketResource::getUrl('index')),
        ];
    }
}
