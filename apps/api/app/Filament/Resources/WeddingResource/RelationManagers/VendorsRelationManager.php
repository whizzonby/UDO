<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class VendorsRelationManager extends RelationManager
{
    protected static string $relationship = 'vendors';
    protected static ?string $title = 'Vendors';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('name')->required()->maxLength(255),
            Forms\Components\TextInput::make('category')->maxLength(100)->label('Category (e.g. Catering, Florist)'),
            Forms\Components\TextInput::make('contact_name')->maxLength(255),
            Forms\Components\TextInput::make('contact_email')->email()->maxLength(255),
            Forms\Components\TextInput::make('contact_phone')->tel()->maxLength(30),
            Forms\Components\TextInput::make('website')->url()->maxLength(500),
            Forms\Components\Select::make('status')
                ->options(['prospect' => 'Prospect', 'contacted' => 'Contacted', 'booked' => 'Booked', 'confirmed' => 'Confirmed', 'completed' => 'Completed', 'cancelled' => 'Cancelled'])
                ->default('prospect'),
            Forms\Components\TextInput::make('contract_amount')->numeric()->prefix('$'),
            Forms\Components\TextInput::make('deposit_amount')->numeric()->prefix('$'),
            Forms\Components\Toggle::make('deposit_paid')->label('Deposit paid'),
            Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('category')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'contacted'             => 'info',
                        'booked'                => 'warning',
                        'confirmed', 'completed' => 'success',
                        'cancelled'             => 'danger',
                        default                 => 'gray',
                    }),
                Tables\Columns\TextColumn::make('contract_amount')->money('usd')->sortable(),
                Tables\Columns\IconColumn::make('deposit_paid')->boolean()->label('Deposit'),
                Tables\Columns\TextColumn::make('contact_email')->copyable()->toggleable(),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }
}
