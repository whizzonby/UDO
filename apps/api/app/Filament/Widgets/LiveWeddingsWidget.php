<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\WeddingResource;
use App\Models\Wedding;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LiveWeddingsWidget extends BaseWidget
{
    protected static ?string $heading = 'Live and final-week weddings';
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Wedding::query()
                    ->with('owner')
                    ->withCount(['guests', 'smartAlerts'])
                    ->whereIn('status', ['final_week', 'live'])
                    ->orderBy('event_date')
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'live' ? 'danger' : 'warning'),
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
            ->emptyStateHeading('No live operations')
            ->emptyStateDescription('No weddings are currently marked final-week or live.');
    }
}
