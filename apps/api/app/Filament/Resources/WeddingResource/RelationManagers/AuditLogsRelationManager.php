<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class AuditLogsRelationManager extends RelationManager
{
    protected static string $relationship = 'auditLogs';
    protected static ?string $title = 'Audit history';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('action')->searchable()->badge()->color('gray'),
                Tables\Columns\TextColumn::make('user.email')->label('Actor')->searchable()->default('System'),
                Tables\Columns\TextColumn::make('auditable_type')->label('Record type')->formatStateUsing(fn (?string $state) => $state ? class_basename($state) : '-'),
                Tables\Columns\TextColumn::make('auditable_id')->label('Record ID')->copyable()->default('-'),
                Tables\Columns\TextColumn::make('ip_address')->copyable()->toggleable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([Actions\ViewAction::make()])
            ->bulkActions([]);
    }
}
