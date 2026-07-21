<?php

namespace App\Filament\Resources\VendorResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class BudgetItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'budgetItems';
    protected static ?string $title = 'Budget balances';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('category')->badge(),
                Tables\Columns\TextColumn::make('actual_amount')->money('USD')->label('Actual'),
                Tables\Columns\TextColumn::make('paid_amount')->money('USD')->label('Paid'),
                Tables\Columns\TextColumn::make('balance_due')
                    ->money('USD')
                    ->getStateUsing(fn ($record) => max(0, (float) max($record->actual_amount, $record->estimated_amount) - (float) $record->paid_amount)),
                Tables\Columns\TextColumn::make('payment_status')->badge(),
                Tables\Columns\TextColumn::make('due_date')->date()->placeholder('-'),
            ])
            ->defaultSort('due_date', 'asc')
            ->actions([
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }
}
