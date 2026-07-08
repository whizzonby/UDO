<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class GuestsRelationManager extends RelationManager
{
    protected static string $relationship = 'guests';
    protected static ?string $title = 'Guests';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('first_name')->required()->maxLength(100),
            Forms\Components\TextInput::make('last_name')->maxLength(100),
            Forms\Components\TextInput::make('email')->email()->maxLength(255),
            Forms\Components\TextInput::make('phone')->tel()->maxLength(30),
            Forms\Components\Select::make('attending_status')
                ->options(['pending' => 'Pending', 'yes' => 'Attending', 'no' => 'Declined', 'maybe' => 'Maybe'])
                ->default('pending'),
            Forms\Components\Select::make('rsvp_status')
                ->options(['not_sent' => 'Not sent', 'sent' => 'Sent', 'opened' => 'Opened', 'responded' => 'Responded'])
                ->default('not_sent'),
            Forms\Components\TextInput::make('meal_preference')->maxLength(100),
            Forms\Components\Toggle::make('plus_one_allowed')->label('Plus one allowed'),
            Forms\Components\TextInput::make('table_number')->numeric()->label('Table number'),
            Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('first_name')
                    ->label('Guest')
                    ->description(fn ($record) => $record->email)
                    ->searchable(['first_name', 'last_name', 'email']),
                Tables\Columns\TextColumn::make('last_name')->searchable()->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('attending_status')
                    ->label('RSVP')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'yes'   => 'success',
                        'no'    => 'danger',
                        'maybe' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('rsvp_status')
                    ->label('Invite')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'sent'      => 'info',
                        'opened'    => 'warning',
                        'responded' => 'success',
                        default     => 'gray',
                    }),
                Tables\Columns\TextColumn::make('meal_preference')->label('Meal')->toggleable(),
                Tables\Columns\TextColumn::make('table_number')->label('Table')->toggleable(),
                Tables\Columns\IconColumn::make('plus_one_allowed')->label('+1')->boolean(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('attending_status')
                    ->options(['pending' => 'Pending', 'yes' => 'Attending', 'no' => 'Declined', 'maybe' => 'Maybe']),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }
}
