<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class AccommodationRelationManager extends RelationManager
{
    protected static string $relationship = 'accommodationOptions';
    protected static ?string $title = 'Accommodation';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('name')->required()->maxLength(255),
            Forms\Components\TextInput::make('type')->maxLength(100),
            Forms\Components\TextInput::make('address')->maxLength(255)->columnSpanFull(),
            Forms\Components\TextInput::make('city')->maxLength(100),
            Forms\Components\TextInput::make('country')->maxLength(100),
            Forms\Components\TextInput::make('total_rooms_blocked')->numeric()->default(0),
            Forms\Components\TextInput::make('rooms_assigned')->numeric()->default(0),
            Forms\Components\TextInput::make('booking_code')->maxLength(100),
            Forms\Components\TextInput::make('website')->url()->maxLength(500),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('type')->badge()->default('-'),
                Tables\Columns\TextColumn::make('city')->searchable(),
                Tables\Columns\TextColumn::make('rooms_assigned')->label('Assigned')->sortable(),
                Tables\Columns\TextColumn::make('total_rooms_blocked')->label('Rooms')->sortable(),
                Tables\Columns\TextColumn::make('booking_code')->copyable()->default('-'),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
