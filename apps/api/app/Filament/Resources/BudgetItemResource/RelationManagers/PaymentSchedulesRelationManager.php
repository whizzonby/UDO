<?php

namespace App\Filament\Resources\BudgetItemResource\RelationManagers;

use App\Filament\Resources\BudgetPaymentScheduleResource;
use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class PaymentSchedulesRelationManager extends RelationManager
{
    protected static string $relationship = 'paymentSchedules';
    protected static ?string $title = 'Payment schedules';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('label')->searchable(),
                Tables\Columns\TextColumn::make('vendor.name')->label('Vendor')->default('-'),
                Tables\Columns\TextColumn::make('amount')->money('USD'),
                Tables\Columns\TextColumn::make('status')->badge()
                    ->color(fn (string $state) => BudgetPaymentScheduleResource::statusColor($state)),
                Tables\Columns\TextColumn::make('due_date')->date()->sortable(),
                Tables\Columns\TextColumn::make('paid_at')->dateTime()->placeholder('-'),
            ])
            ->defaultSort('due_date', 'asc')
            ->headerActions([
                Actions\CreateAction::make(),
            ])
            ->actions([
                BudgetPaymentScheduleResource::markPaidAction(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }
}
