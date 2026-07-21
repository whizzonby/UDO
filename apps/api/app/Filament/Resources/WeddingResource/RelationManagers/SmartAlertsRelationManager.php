<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class SmartAlertsRelationManager extends RelationManager
{
    protected static string $relationship = 'smartAlerts';
    protected static ?string $title = 'Smart alerts';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('severity')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'critical' => 'danger',
                        'high' => 'warning',
                        'medium' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('title')->searchable()->description(fn ($record) => $record->body)->limit(50),
                Tables\Columns\TextColumn::make('target')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('status')->badge()->color(fn (string $state): string => $state === 'active' ? 'warning' : 'success'),
                Tables\Columns\TextColumn::make('trigger_at')->label('Due')->since()->sortable(),
                Tables\Columns\TextColumn::make('resolved_at')->since()->placeholder('-'),
            ])
            ->defaultSort('trigger_at')
            ->actions([Actions\ViewAction::make()]);
    }
}
