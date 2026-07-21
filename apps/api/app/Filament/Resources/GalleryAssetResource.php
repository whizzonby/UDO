<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GalleryAssetResource\Pages;
use App\Filament\Resources\GalleryAssetResource\RelationManagers;
use App\Models\GalleryAsset;
use App\Services\AdminGalleryModerationService;
use Filament\Forms;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class GalleryAssetResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = GalleryAsset::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-photo';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 9;
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

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Asset context')->columns(3)->schema([
                Infolists\Components\ImageEntry::make('thumbnail_url')->label('Preview')->defaultImageUrl(fn (GalleryAsset $asset) => $asset->url),
                Infolists\Components\TextEntry::make('original_filename')->default('(no filename)'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('uploadedByUser.email')->label('Uploaded by user')->default('-'),
                Infolists\Components\TextEntry::make('uploadedByGuest.full_name')->label('Uploaded by guest')->default('-'),
                Infolists\Components\TextEntry::make('source')->badge(),
                Infolists\Components\TextEntry::make('album')->badge(),
                Infolists\Components\IconEntry::make('approved')->boolean(),
                Infolists\Components\IconEntry::make('is_featured')->boolean()->label('Featured'),
                Infolists\Components\IconEntry::make('is_saved')->boolean()->label('Saved'),
                Infolists\Components\TextEntry::make('file_size_bytes')->numeric()->default('-'),
                Infolists\Components\TextEntry::make('url')->copyable()->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Caption')->schema([
                Infolists\Components\TextEntry::make('caption')->default('-')->columnSpanFull(),
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
                Tables\Columns\TextColumn::make('uploadedByGuest.full_name')->label('Guest')->toggleable()->default('-'),
                Tables\Columns\TextColumn::make('uploadedByUser.email')->label('User')->toggleable(isToggledHiddenByDefault: true)->default('-'),
                Tables\Columns\IconColumn::make('approved')->boolean()->label('Approved'),
                Tables\Columns\IconColumn::make('is_featured')->boolean()->label('Featured'),
                Tables\Columns\IconColumn::make('is_saved')->boolean()->label('Saved'),
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
            ->actions([
                Actions\ViewAction::make(),
                static::moderationAction('approve', 'Approve', 'heroicon-o-check-circle', 'success'),
                static::moderationAction('reject', 'Reject', 'heroicon-o-x-circle', 'danger'),
                static::moderationAction('feature', 'Feature', 'heroicon-o-star', 'warning'),
                static::moderationAction('archive', 'Archive', 'heroicon-o-archive-box', 'gray'),
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\SubjectAuditLogsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListGalleryAssets::route('/'),
            'create' => Pages\CreateGalleryAsset::route('/create'),
            'view'   => Pages\ViewGalleryAsset::route('/{record}'),
            'edit'   => Pages\EditGalleryAsset::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('approved', false)->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string { return 'danger'; }

    public static function getNavigationLabel(): string { return 'Gallery'; }

    public static function moderationAction(string $action, string $label, string $icon, string $color): Actions\Action
    {
        return Actions\Action::make($action)
            ->label($label)
            ->icon($icon)
            ->color($color)
            ->requiresConfirmation()
            ->form([
                Forms\Components\Textarea::make('note')->maxLength(500),
            ])
            ->action(function (GalleryAsset $record, array $data, AdminGalleryModerationService $moderation) use ($action, $label): void {
                $moderation->moderate($record, auth()->user(), $action, $data['note'] ?? null);

                Notification::make()->title("Asset {$label}")->success()->send();
            });
    }
}
