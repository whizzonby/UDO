<?php

namespace App\Filament\Resources\RegistryContributionResource\RelationManagers;

use App\Filament\Resources\ThankYouRecordResource;
use Filament\Actions;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ThankYouRecordRelationManager extends RelationManager
{
    protected static string $relationship = 'thankYouRecord';
    protected static ?string $title = 'Thank-you';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('recipient_name'),
                Tables\Columns\TextColumn::make('status')->badge(),
                Tables\Columns\TextColumn::make('channel')->badge(),
                Tables\Columns\TextColumn::make('sent_at')->dateTime()->placeholder('-'),
            ])
            ->actions([
                ThankYouRecordResource::markSentAction(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }
}
