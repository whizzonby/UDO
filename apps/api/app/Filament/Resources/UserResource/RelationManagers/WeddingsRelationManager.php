<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class WeddingsRelationManager extends RelationManager
{
    protected static string $relationship = 'ownedWeddings';
    protected static ?string $title = 'Weddings';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('couple_name_primary')->required()->maxLength(255),
            Forms\Components\TextInput::make('couple_name_secondary')->maxLength(255),
            Forms\Components\DatePicker::make('event_date')->native(false),
            Forms\Components\Select::make('status')
                ->options(['planning' => 'Planning', 'live' => 'Live', 'completed' => 'Completed'])
                ->default('planning'),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('couple_name_primary')->label('Couple')->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'live'      => 'danger',
                        'completed' => 'success',
                        default     => 'info',
                    }),
                Tables\Columns\TextColumn::make('event_date')->date('d M Y'),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
