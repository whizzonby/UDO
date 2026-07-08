<?php

namespace App\Filament\Resources\WeddingResource\RelationManagers;

use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class GalleryAssetsRelationManager extends RelationManager
{
    protected static string $relationship = 'galleryAssets';
    protected static ?string $title = 'Gallery';

    public function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('file_url')->url()->required()->maxLength(500)->label('File URL')->columnSpanFull(),
            Forms\Components\Select::make('asset_type')
                ->options(['photo' => 'Photo', 'video' => 'Video', 'document' => 'Document'])
                ->default('photo'),
            Forms\Components\TextInput::make('caption')->maxLength(255),
            Forms\Components\Toggle::make('is_featured')->label('Featured'),
            Forms\Components\Toggle::make('is_visible')->label('Visible to guests')->default(true),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('file_url')->label('Preview')->circular(false),
                Tables\Columns\TextColumn::make('caption')->limit(40)->searchable(),
                Tables\Columns\TextColumn::make('asset_type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'photo'    => 'info',
                        'video'    => 'warning',
                        default    => 'gray',
                    }),
                Tables\Columns\IconColumn::make('is_featured')->boolean()->label('Featured'),
                Tables\Columns\IconColumn::make('is_visible')->boolean()->label('Visible'),
                Tables\Columns\TextColumn::make('created_at')->since(),
            ])
            ->headerActions([Actions\CreateAction::make()])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }
}
