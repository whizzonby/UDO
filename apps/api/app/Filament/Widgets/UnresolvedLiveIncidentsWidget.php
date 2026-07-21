<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\LiveUpdateResource;
use App\Filament\Resources\WeddingResource;
use App\Models\LiveUpdate;
use Filament\Actions;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class UnresolvedLiveIncidentsWidget extends BaseWidget
{
    protected static ?string $heading = 'Unresolved incidents and actions';
    protected static ?int $sort = 2;
    protected static bool $isLazy = false;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                LiveUpdate::query()
                    ->with('wedding')
                    ->whereHas('wedding', fn ($query) => $query->whereIn('status', ['final_week', 'live']))
                    ->where('status', '!=', 'resolved')
                    ->where(function ($query) {
                        $query->where('requires_action', true)
                            ->orWhereIn('type', ['incident', 'alert']);
                    })
                    ->orderByRaw("case severity when 'critical' then 1 when 'high' then 2 when 'medium' then 3 when 'low' then 4 else 5 end")
                    ->orderByDesc('created_at')
                    ->limit(15)
            )
            ->columns([
                Tables\Columns\TextColumn::make('severity')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'critical' => 'danger', 'high' => 'warning', 'medium' => 'info', default => 'gray',
                    })
                    ->default('-'),
                Tables\Columns\TextColumn::make('type')->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'alert', 'incident' => 'danger', 'vip' => 'warning', default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('title')
                    ->description(fn (LiveUpdate $update) => $update->body)
                    ->limit(50)
                    ->default('(untitled)'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->url(fn (LiveUpdate $update) => $update->wedding ? WeddingResource::getUrl('view', ['record' => $update->wedding]) : null),
                Tables\Columns\IconColumn::make('requires_action')->boolean()->label('Action'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->actions([
                LiveUpdateResource::resolveAction(),
            ])
            ->emptyStateHeading('No unresolved incidents')
            ->emptyStateDescription('Every incident and flagged action across live and final-week weddings is resolved.');
    }
}
