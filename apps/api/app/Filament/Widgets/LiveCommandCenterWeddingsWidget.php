<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\WeddingResource;
use App\Models\Wedding;
use App\Services\AdminLiveOpsService;
use Filament\Actions;
use Filament\Notifications\Notification;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LiveCommandCenterWeddingsWidget extends BaseWidget
{
    protected static ?string $heading = 'Live, final-week and upcoming weddings';
    protected static ?int $sort = 1;
    protected static bool $isLazy = false;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Wedding::query()
                    ->with('owner')
                    ->withCount(['guests', 'smartAlerts'])
                    ->where(function ($query) {
                        $query->whereIn('status', ['final_week', 'live'])
                            ->orWhere(function ($query) {
                                $query->where('status', 'planning')
                                    ->whereBetween('event_date', [now()->toDateString(), now()->addDays(7)->toDateString()]);
                            });
                    })
                    ->orderByRaw("case status when 'live' then 1 when 'final_week' then 2 else 3 end")
                    ->orderBy('event_date')
                    ->limit(15)
            )
            ->columns([
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (Wedding $wedding) => $wedding->status === 'planning' ? 'Upcoming' : ucfirst(str_replace('_', ' ', $wedding->status)))
                    ->color(fn (Wedding $wedding): string => match ($wedding->status) {
                        'live' => 'danger',
                        'final_week' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('couple_name_primary')
                    ->label('Wedding')
                    ->description(fn (Wedding $wedding) => $wedding->couple_name_secondary)
                    ->searchable()
                    ->url(fn (Wedding $wedding) => WeddingResource::getUrl('view', ['record' => $wedding])),
                Tables\Columns\TextColumn::make('event_date')
                    ->date('d M Y')
                    ->sortable(),
                Tables\Columns\TextColumn::make('owner.email')
                    ->label('Owner')
                    ->copyable(),
                Tables\Columns\TextColumn::make('guests_count')
                    ->label('Guests')
                    ->sortable(),
                Tables\Columns\TextColumn::make('smart_alerts_count')
                    ->label('Alerts')
                    ->badge()
                    ->color(fn (int $state): string => $state > 0 ? 'warning' : 'success'),
            ])
            ->actions([
                Actions\Action::make('markFinalWeek')
                    ->label('Mark final week')
                    ->icon('heroicon-o-calendar-days')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->visible(fn (Wedding $wedding) => $wedding->status === 'planning')
                    ->action(function (Wedding $wedding, AdminLiveOpsService $liveOps): void {
                        $liveOps->markFinalWeek($wedding, auth()->user());

                        Notification::make()->title('Wedding marked final week')->success()->send();
                    }),
                Actions\Action::make('startLive')
                    ->label('Start live')
                    ->icon('heroicon-o-bolt')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn (Wedding $wedding) => $wedding->status !== 'live')
                    ->action(function (Wedding $wedding, AdminLiveOpsService $liveOps): void {
                        $liveOps->startLive($wedding, auth()->user());

                        Notification::make()->title('Wedding marked live')->success()->send();
                    }),
            ])
            ->emptyStateHeading('No live operations')
            ->emptyStateDescription('No weddings are currently live, final-week, or due within 7 days.');
    }
}
