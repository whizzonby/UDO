<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class TeamRelationManager extends RelationManager
{
    protected static string $relationship = 'collaborators';
    protected static ?string $title = 'Team';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\Select::make('user_id')
                ->relationship('user', 'email')
                ->searchable()
                ->required()
                ->label('User'),
            Forms\Components\Select::make('role')
                ->options([
                    'planner' => 'Planner',
                    'finance' => 'Finance',
                    'day_of_coordinator' => 'Day-of coordinator',
                    'viewer' => 'Viewer',
                ])
                ->required(),
            Forms\Components\TagsInput::make('permissions')
                ->suggestions(['manage_guests', 'manage_messages', 'manage_plan', 'manage_budget', 'manage_wedding', 'view_reports']),
            Forms\Components\DateTimePicker::make('accepted_at')->native(false),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.email')->label('User')->searchable()->copyable(),
                Tables\Columns\TextColumn::make('role')->badge(),
                Tables\Columns\TextColumn::make('permissions')->badge()->separator(', ')->default('-'),
                Tables\Columns\TextColumn::make('accepted_at')->since()->placeholder('-'),
                Tables\Columns\TextColumn::make('created_at')->label('Invited')->since(),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()]);
    }
}
