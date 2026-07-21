<?php

namespace App\Filament\Resources\RegistryContributionResource\RelationManagers;

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
                Tables\Columns\TextColumn::make('created_at')->dateTime()->sortable(),
                Tables\Columns\TextColumn::make('action')->badge(),
                Tables\Columns\TextColumn::make('user.email')->label('Actor')->default('System'),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([])
            ->bulkActions([]);
    }
}
