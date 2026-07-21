<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class SupportTicketsRelationManager extends RelationManager
{
    protected static string $relationship = 'supportTickets';
    protected static ?string $title = 'Support tickets';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reference')->copyable()->searchable(),
                Tables\Columns\TextColumn::make('user.email')->label('Reported by')->searchable(),
                Tables\Columns\TextColumn::make('subject')->limit(40)->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'in_progress'     => 'warning',
                        'waiting_on_user' => 'info',
                        'resolved'        => 'success',
                        'closed'          => 'danger',
                        default           => 'gray',
                    }),
                Tables\Columns\TextColumn::make('priority')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'normal'  => 'info',
                        'high'    => 'warning',
                        'urgent'  => 'danger',
                        default   => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')->since(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([Actions\ViewAction::make()])
            ->bulkActions([]);
    }
}
