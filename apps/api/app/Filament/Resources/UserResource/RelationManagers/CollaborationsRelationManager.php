<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class CollaborationsRelationManager extends RelationManager
{
    protected static string $relationship = 'collaborations';
    protected static ?string $title = 'Wedding collaborations';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->searchable(),
                Tables\Columns\TextColumn::make('role')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'planner' => 'success',
                        'finance' => 'warning',
                        'viewer' => 'gray',
                        default => 'info',
                    }),
                Tables\Columns\TextColumn::make('permissions')
                    ->badge()
                    ->separator(', ')
                    ->default('-'),
                Tables\Columns\TextColumn::make('accepted_at')
                    ->label('Accepted')
                    ->since()
                    ->placeholder('-'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Invited')
                    ->since(),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ]);
    }
}
