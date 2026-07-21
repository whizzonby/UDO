<?php

namespace App\Filament\Resources\BudgetPaymentScheduleResource\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class SubjectAuditLogsRelationManager extends RelationManager
{
    protected static string $relationship = 'subjectAuditLogs';
    protected static ?string $title = 'Audit evidence';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')->label('When')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('action')->badge()->searchable(),
                Tables\Columns\TextColumn::make('user.email')->label('Actor')->searchable()->default('System'),
                Tables\Columns\TextColumn::make('metadata')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->wrap()
                    ->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([])
            ->bulkActions([]);
    }
}
