<?php

namespace App\Filament\Resources;

use App\Filament\Resources\GalleryAssetResource\Pages;
use App\Models\GalleryAsset;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class GalleryAssetResource extends Resource
{
    protected static ?string $model = GalleryAsset::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-photo';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 4;
    protected static ?string $recordTitleAttribute = 'original_filename';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Asset')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('album')
                    ->options(['moments' => 'Moments', 'inspiration' => 'Inspiration', 'guest_uploads' => 'Guest Uploads', 'archive' => 'Archive'])
                    ->default('moments'),
                Forms\Components\Select::make('type')
                    ->options(['photo' => 'Photo', 'video' => 'Video'])
                    ->default('photo')->required(),
                Forms\Components\Select::make('source')
                    ->options(['upload' => 'Upload', 'pinterest' => 'Pinterest', 'instagram' => 'Instagram'])
                    ->default('upload')->required(),
                Forms\Components\TextInput::make('url')->required()->url()->maxLength(2048)->columnSpanFull()->label('URL'),
                Forms\Components\TextInput::make('thumbnail_url')->url()->maxLength(2048)->columnSpanFull()->label('Thumbnail URL'),
                Forms\Components\TextInput::make('caption')->maxLength(255)->columnSpanFull(),
                Forms\Components\Toggle::make('is_featured')->label('Featured'),
                Forms\Components\Toggle::make('approved')->label('Approved')->default(true),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('thumbnail_url')->label('Preview')->circular(false)->height(48)->width(64)->defaultImageUrl(fn ($r) => $r->url),
                Tables\Columns\TextColumn::make('original_filename')->searchable()->limit(40)->default('(no filename)'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('album')->badge()->color('info'),
                Tables\Columns\TextColumn::make('type')->badge()
                    ->color(fn ($s) => $s === 'video' ? 'warning' : 'gray'),
                Tables\Columns\TextColumn::make('source')->badge()->color('gray'),
                Tables\Columns\IconColumn::make('approved')->boolean()->label('Approved'),
                Tables\Columns\IconColumn::make('is_featured')->boolean()->label('Featured'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('approved')->label('Approval status'),
                Tables\Filters\SelectFilter::make('album')
                    ->options(['moments' => 'Moments', 'inspiration' => 'Inspiration', 'guest_uploads' => 'Guest Uploads', 'archive' => 'Archive']),
                Tables\Filters\SelectFilter::make('type')
                    ->options(['photo' => 'Photo', 'video' => 'Video']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListGalleryAssets::route('/'),
            'create' => Pages\CreateGalleryAsset::route('/create'),
            'edit'   => Pages\EditGalleryAsset::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('approved', false)->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string { return 'danger'; }

    public static function getNavigationLabel(): string { return 'Gallery'; }
}
