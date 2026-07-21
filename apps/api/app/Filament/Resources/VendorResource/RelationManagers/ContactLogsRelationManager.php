<?php

namespace App\Filament\Resources\VendorResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ContactLogsRelationManager extends RelationManager
{
    protected static string $relationship = 'contactLogs';
    protected static ?string $title = 'Contact logs';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('contact_at')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('contact_type')->badge(),
                Tables\Columns\TextColumn::make('subject')->searchable()->wrap(),
                Tables\Columns\TextColumn::make('outcome')->searchable()->wrap()->default('-'),
                Tables\Columns\TextColumn::make('follow_up_at')->label('Follow-up')->dateTime()->sortable()->placeholder('-'),
                Tables\Columns\TextColumn::make('creator.email')->label('Created by')->default('System'),
            ])
            ->actions([
                Actions\EditAction::make(),
            ])
            ->defaultSort('contact_at', 'desc')
            ->bulkActions([]);
    }
}
