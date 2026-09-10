<?php

namespace App\Filament\Resources\CouponResource\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class RedemptionsRelationManager extends RelationManager
{
    protected static string $relationship = 'redemptions';
    protected static ?string $title = 'Redemptions';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.email')->label('User')->copyable()->searchable(),
                Tables\Columns\TextColumn::make('amount_discounted_cents')
                    ->label('Discount')
                    ->formatStateUsing(fn ($state) => '$' . number_format($state / 100, 2)),
                Tables\Columns\TextColumn::make('stripe_checkout_session_id')
                    ->label('Stripe session')
                    ->copyable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('redeemed_at')->dateTime()->sortable(),
            ])
            ->defaultSort('redeemed_at', 'desc')
            ->actions([])
            ->bulkActions([]);
    }
}
