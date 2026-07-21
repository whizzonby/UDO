<?php

namespace App\Filament\Resources\VendorResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class TasksRelationManager extends RelationManager
{
    protected static string $relationship = 'tasks';
    protected static ?string $title = 'Linked tasks';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->wrap(),
                Tables\Columns\TextColumn::make('priority')->badge(),
                Tables\Columns\TextColumn::make('due_date')->date()->sortable()->placeholder('-'),
                Tables\Columns\IconColumn::make('completed')->boolean(),
                Tables\Columns\TextColumn::make('assignee.email')->label('Assigned to')->default('-'),
            ])
            ->defaultSort('due_date', 'asc')
            ->actions([
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }
}
