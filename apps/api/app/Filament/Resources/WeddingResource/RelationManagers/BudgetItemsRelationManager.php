<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class BudgetItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'budgetItems';
    protected static ?string $title = 'Budget';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('category')->required()->maxLength(100),
            Forms\Components\TextInput::make('name')->required()->maxLength(255),
            Forms\Components\TextInput::make('estimated_amount')->numeric()->prefix('$')->label('Estimated'),
            Forms\Components\TextInput::make('actual_amount')->numeric()->prefix('$')->label('Actual'),
            Forms\Components\Select::make('payment_status')
                ->options(['unpaid' => 'Unpaid', 'deposit_paid' => 'Deposit paid', 'paid' => 'Paid'])
                ->default('unpaid'),
            Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('category')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('estimated_amount')->money('usd')->sortable()->label('Estimated'),
                Tables\Columns\TextColumn::make('actual_amount')->money('usd')->sortable()->label('Actual'),
                Tables\Columns\TextColumn::make('payment_status')
                    ->label('Payment')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'deposit_paid' => 'warning',
                        'paid'         => 'success',
                        default        => 'gray',
                    }),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }
}
