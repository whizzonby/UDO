<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class LiveUpdatesRelationManager extends RelationManager
{
    protected static string $relationship = 'liveUpdates';
    protected static ?string $title = 'Live mode';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('title')->required()->maxLength(255)->columnSpanFull(),
            Forms\Components\Textarea::make('body')->rows(3)->columnSpanFull(),
            Forms\Components\Select::make('type')
                ->options(['update' => 'Update', 'incident' => 'Incident', 'announcement' => 'Announcement'])
                ->default('update'),
            Forms\Components\Select::make('severity')
                ->options(['info' => 'Info', 'low' => 'Low', 'medium' => 'Medium', 'high' => 'High'])
                ->default('info'),
            Forms\Components\Select::make('audience')
                ->options(['all' => 'All', 'team' => 'Team', 'guests' => 'Guests'])
                ->default('all'),
            Forms\Components\Select::make('status')
                ->options(['open' => 'Open', 'resolved' => 'Resolved'])
                ->default('open'),
            Forms\Components\Toggle::make('visible_to_guests'),
            Forms\Components\Toggle::make('requires_action'),
            Forms\Components\Toggle::make('pinned'),
            Forms\Components\DateTimePicker::make('event_time')->native(false),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->limit(50),
                Tables\Columns\TextColumn::make('type')->badge(),
                Tables\Columns\TextColumn::make('severity')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'high' => 'danger',
                        'medium' => 'warning',
                        default => 'info',
                    }),
                Tables\Columns\TextColumn::make('status')->badge()->color(fn (string $state): string => $state === 'resolved' ? 'success' : 'warning'),
                Tables\Columns\IconColumn::make('visible_to_guests')->boolean()->label('Guests'),
                Tables\Columns\IconColumn::make('requires_action')->boolean()->label('Action'),
                Tables\Columns\TextColumn::make('event_time')->dateTime()->sortable(),
            ])
            ->defaultSort('event_time', 'desc')
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
