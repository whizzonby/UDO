<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\WeddingResource;
use App\Models\SmartAlert;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class ActiveSmartAlertsWidget extends BaseWidget
{
    protected static ?string $heading = 'Active smart alerts';
    protected static ?int $sort = 2;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                SmartAlert::query()
                    ->with('wedding')
                    ->where('status', 'active')
                    ->orderByRaw("case severity when 'critical' then 1 when 'high' then 2 when 'medium' then 3 else 4 end")
                    ->orderBy('trigger_at')
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('severity')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'critical' => 'danger',
                        'high' => 'warning',
                        'medium' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->description(fn (SmartAlert $alert) => $alert->body)
                    ->limit(50),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->url(fn (SmartAlert $alert) => $alert->wedding ? WeddingResource::getUrl('view', ['record' => $alert->wedding]) : null),
                Tables\Columns\TextColumn::make('target')
                    ->badge()
                    ->color('gray'),
                Tables\Columns\TextColumn::make('trigger_at')
                    ->label('Due')
                    ->since()
                    ->sortable(),
            ])
            ->emptyStateHeading('No active smart alerts')
            ->emptyStateDescription('The platform has no active generated wedding alerts right now.');
    }
}
