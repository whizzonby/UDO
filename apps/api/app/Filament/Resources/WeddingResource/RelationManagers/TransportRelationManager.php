<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class TransportRelationManager extends RelationManager
{
    protected static string $relationship = 'transportGroups';
    protected static ?string $title = 'Transport';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('name')->required()->maxLength(255),
            Forms\Components\TextInput::make('type')->maxLength(100),
            Forms\Components\TextInput::make('pickup_location')->maxLength(255),
            Forms\Components\TextInput::make('dropoff_location')->maxLength(255),
            Forms\Components\DateTimePicker::make('departure_time')->native(false),
            Forms\Components\TextInput::make('capacity')->numeric(),
            Forms\Components\TextInput::make('assigned_count')->numeric()->default(0),
            Forms\Components\TextInput::make('driver_name')->maxLength(255),
            Forms\Components\TextInput::make('driver_phone')->tel()->maxLength(50),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('type')->badge()->default('-'),
                Tables\Columns\TextColumn::make('departure_time')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('pickup_location')->limit(30),
                Tables\Columns\TextColumn::make('assigned_count')->label('Assigned')->sortable(),
                Tables\Columns\TextColumn::make('capacity')->sortable(),
                Tables\Columns\TextColumn::make('driver_name')->default('-'),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
