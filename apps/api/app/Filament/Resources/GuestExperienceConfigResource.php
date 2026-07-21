<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GuestExperienceConfigResource\Pages;
use App\Models\GuestExperienceConfig;
use BackedEnum;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class GuestExperienceConfigResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = GuestExperienceConfig::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-device-phone-mobile';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 5;
    protected static ?string $navigationLabel = 'Guest Experience';
    protected static ?string $recordTitleAttribute = 'welcome_message';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Publishing')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required()
                    ->label('Wedding'),
                Forms\Components\Select::make('publish_state')
                    ->options(['draft' => 'Draft', 'published' => 'Published', 'paused' => 'Paused'])
                    ->default('draft')
                    ->required(),
                Forms\Components\DateTimePicker::make('published_at')->native(false),
                Forms\Components\TextInput::make('theme_color')->maxLength(20)->placeholder('#285301'),
            ]),
            \Filament\Schemas\Components\Section::make('Guest-facing copy')->schema([
                Forms\Components\Textarea::make('welcome_message')->rows(3)->columnSpanFull(),
                Forms\Components\TextInput::make('dress_code')->maxLength(255),
                Forms\Components\TextInput::make('cover_image_url')->url()->maxLength(500),
                Forms\Components\Textarea::make('dress_code_details')->rows(3)->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Sections')->columns(3)->schema([
                Forms\Components\Toggle::make('show_schedule')->default(true),
                Forms\Components\Toggle::make('show_venue_map')->default(true),
                Forms\Components\Toggle::make('show_accommodation')->default(true),
                Forms\Components\Toggle::make('show_transport')->default(true),
                Forms\Components\Toggle::make('show_seating'),
                Forms\Components\Toggle::make('show_dress_code')->default(true),
                Forms\Components\Toggle::make('show_registry')->default(true),
                Forms\Components\Toggle::make('show_gallery'),
                Forms\Components\Toggle::make('show_live_feed'),
            ]),
            \Filament\Schemas\Components\Section::make('Guest actions')->columns(3)->schema([
                Forms\Components\Toggle::make('rsvp_enabled')->default(true),
                Forms\Components\Toggle::make('meal_selection_enabled')->default(true),
                Forms\Components\Toggle::make('plus_one_enabled')->default(true),
                Forms\Components\Toggle::make('allow_photo_uploads'),
                Forms\Components\Toggle::make('allow_messages'),
            ]),
            \Filament\Schemas\Components\Section::make('Advanced rules')->columns(2)->schema([
                Forms\Components\TagsInput::make('layout_order'),
                Forms\Components\KeyValue::make('access_rules')->columnSpanFull(),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Publishing')->columns(4)->schema([
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('publish_state')->badge()->color(fn (string $state): string => $state === 'published' ? 'success' : 'warning'),
                Infolists\Components\TextEntry::make('published_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('theme_color')->default('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Enabled sections')->columns(5)->schema([
                Infolists\Components\IconEntry::make('show_schedule')->boolean(),
                Infolists\Components\IconEntry::make('show_accommodation')->boolean(),
                Infolists\Components\IconEntry::make('show_transport')->boolean(),
                Infolists\Components\IconEntry::make('show_seating')->boolean(),
                Infolists\Components\IconEntry::make('show_registry')->boolean(),
                Infolists\Components\IconEntry::make('show_gallery')->boolean(),
                Infolists\Components\IconEntry::make('show_live_feed')->boolean(),
                Infolists\Components\IconEntry::make('allow_photo_uploads')->boolean(),
                Infolists\Components\IconEntry::make('rsvp_enabled')->boolean(),
                Infolists\Components\IconEntry::make('meal_selection_enabled')->boolean(),
            ]),
            \Filament\Schemas\Components\Section::make('Copy')->schema([
                Infolists\Components\TextEntry::make('welcome_message')->default('-')->columnSpanFull(),
                Infolists\Components\TextEntry::make('dress_code')->default('-'),
                Infolists\Components\TextEntry::make('dress_code_details')->default('-')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('publish_state')->badge()->color(fn (string $state): string => $state === 'published' ? 'success' : 'warning'),
                Tables\Columns\IconColumn::make('rsvp_enabled')->boolean()->label('RSVP'),
                Tables\Columns\IconColumn::make('show_gallery')->boolean()->label('Gallery'),
                Tables\Columns\IconColumn::make('allow_photo_uploads')->boolean()->label('Uploads'),
                Tables\Columns\TextColumn::make('published_at')->since()->placeholder('-')->sortable(),
                Tables\Columns\TextColumn::make('updated_at')->since()->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('publish_state')
                    ->options(['draft' => 'Draft', 'published' => 'Published', 'paused' => 'Paused']),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->label('Wedding'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make(),
                Actions\Action::make('publish')
                    ->label('Publish')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn (GuestExperienceConfig $record) => $record->publish_state !== 'published')
                    ->action(function (GuestExperienceConfig $record): void {
                        $record->update(['publish_state' => 'published', 'published_at' => now()]);
                        Notification::make()->title('Guest experience published')->success()->send();
                    }),
                Actions\Action::make('pause')
                    ->label('Pause')
                    ->icon('heroicon-o-pause-circle')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->visible(fn (GuestExperienceConfig $record) => $record->publish_state === 'published')
                    ->action(function (GuestExperienceConfig $record): void {
                        $record->update(['publish_state' => 'paused']);
                        Notification::make()->title('Guest experience paused')->success()->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListGuestExperienceConfigs::route('/'),
            'create' => Pages\CreateGuestExperienceConfig::route('/create'),
            'view' => Pages\ViewGuestExperienceConfig::route('/{record}'),
            'edit' => Pages\EditGuestExperienceConfig::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $drafts = static::getModel()::where('publish_state', '!=', 'published')->count();
        return $drafts ?: null;
    }
}
