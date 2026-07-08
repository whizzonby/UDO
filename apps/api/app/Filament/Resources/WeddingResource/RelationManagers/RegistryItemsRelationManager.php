<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class RegistryItemsRelationManager extends RelationManager
{
    protected static string $relationship = 'registryItems';
    protected static ?string $title = 'Registry';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('name')->required()->maxLength(255)->columnSpanFull(),
            Forms\Components\TextInput::make('category')->maxLength(100),
            Forms\Components\TextInput::make('target_amount')->numeric()->prefix('$')->label('Target amount'),
            Forms\Components\Textarea::make('description')->rows(2)->columnSpanFull(),
            Forms\Components\TextInput::make('image_url')->url()->maxLength(500)->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('category')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('target_amount')->money('usd'),
                Tables\Columns\TextColumn::make('contributions_count')
                    ->label('Contributions')
                    ->counts('contributions'),
                Tables\Columns\TextColumn::make('contributions_sum_amount')
                    ->label('Raised')
                    ->sum('contributions', 'amount')
                    ->money('usd'),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
