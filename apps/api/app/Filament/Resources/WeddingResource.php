<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WeddingResource\Pages;
use App\Filament\Resources\WeddingResource\RelationManagers;
use App\Models\Wedding;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class WeddingResource extends Resource
{
    protected static ?string $model = Wedding::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-heart';
    protected static string|\UnitEnum|null $navigationGroup = 'Platform';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Couple')->columns(2)->schema([
                Forms\Components\TextInput::make('couple_name_primary')->required()->label('Primary name')->maxLength(255),
                Forms\Components\TextInput::make('couple_name_secondary')->label('Secondary name')->maxLength(255),
                Forms\Components\TextInput::make('title')->label('Wedding title (optional)')->maxLength(255)->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Event details')->columns(2)->schema([
                Forms\Components\DatePicker::make('event_date')->native(false),
                Forms\Components\DatePicker::make('rsvp_deadline')->native(false)->label('RSVP deadline'),
                Forms\Components\TextInput::make('primary_venue_name')->label('Venue name')->maxLength(255),
                Forms\Components\Textarea::make('primary_venue_address')->label('Venue address')->rows(2),
                Forms\Components\TextInput::make('city')->maxLength(100),
                Forms\Components\TextInput::make('country')->maxLength(100),
                Forms\Components\Select::make('timezone')
                    ->options(collect(timezone_identifiers_list())->mapWithKeys(fn ($tz) => [$tz => $tz]))
                    ->searchable()
                    ->default('UTC'),
            ]),
            \Filament\Schemas\Components\Section::make('Status')->columns(2)->schema([
                Forms\Components\Select::make('status')
                    ->options([
                        'planning'     => 'Planning',
                        'final_week'   => 'Final week',
                        'live'         => 'Live',
                        'completed'    => 'Completed',
                        'post_wedding' => 'Post wedding',
                    ])
                    ->default('planning')
                    ->required(),
                Forms\Components\Select::make('owner_user_id')
                    ->relationship('owner', 'email')
                    ->searchable()
                    ->required()
                    ->label('Owner (user)'),
                Forms\Components\TextInput::make('slug')->disabled()->label('Slug (auto-generated)'),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Overview')->columns(3)->schema([
                Infolists\Components\TextEntry::make('couple_name_primary')->label('Primary'),
                Infolists\Components\TextEntry::make('couple_name_secondary')->label('Secondary'),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'planning'     => 'info',
                        'final_week'   => 'warning',
                        'live'         => 'danger',
                        'completed'    => 'success',
                        default        => 'gray',
                    }),
                Infolists\Components\TextEntry::make('event_date')->date()->label('Wedding date'),
                Infolists\Components\TextEntry::make('rsvp_deadline')->date()->label('RSVP deadline'),
                Infolists\Components\TextEntry::make('primary_venue_name')->label('Venue'),
                Infolists\Components\TextEntry::make('city'),
                Infolists\Components\TextEntry::make('country'),
                Infolists\Components\TextEntry::make('owner.email')->label('Owner'),
            ]),
            \Filament\Schemas\Components\Section::make('Counts')->columns(4)->schema([
                Infolists\Components\TextEntry::make('guests_count')
                    ->label('Guests')
                    ->getStateUsing(fn (Wedding $w) => $w->guests()->count()),
                Infolists\Components\TextEntry::make('tasks_count')
                    ->label('Tasks')
                    ->getStateUsing(fn (Wedding $w) => $w->tasks()->count()),
                Infolists\Components\TextEntry::make('vendors_count')
                    ->label('Vendors')
                    ->getStateUsing(fn (Wedding $w) => $w->vendors()->count()),
                Infolists\Components\TextEntry::make('gallery_count')
                    ->label('Gallery assets')
                    ->getStateUsing(fn (Wedding $w) => $w->galleryAssets()->count()),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->sortable(),
                Tables\Columns\TextColumn::make('couple_name_primary')
                    ->label('Couple')
                    ->description(fn (Wedding $w) => $w->couple_name_secondary)
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'planning'     => 'info',
                        'final_week'   => 'warning',
                        'live'         => 'danger',
                        'completed'    => 'success',
                        default        => 'gray',
                    }),
                Tables\Columns\TextColumn::make('event_date')->date('d M Y')->sortable(),
                Tables\Columns\TextColumn::make('primary_venue_name')->label('Venue')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('city')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('owner.email')->label('Owner')->searchable(),
                Tables\Columns\TextColumn::make('guests_count')
                    ->label('Guests')
                    ->counts('guests')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable()->toggleable(),
            ])
            ->defaultSort('event_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'planning'     => 'Planning',
                        'final_week'   => 'Final week',
                        'live'         => 'Live',
                        'completed'    => 'Completed',
                        'post_wedding' => 'Post wedding',
                    ]),
                Tables\Filters\Filter::make('upcoming')
                    ->query(fn ($query) => $query->where('event_date', '>=', now()))
                    ->label('Upcoming only'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\GuestsRelationManager::class,
            RelationManagers\TasksRelationManager::class,
            RelationManagers\VendorsRelationManager::class,
            RelationManagers\BudgetItemsRelationManager::class,
            RelationManagers\GalleryAssetsRelationManager::class,
            RelationManagers\RegistryItemsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListWeddings::route('/'),
            'create' => Pages\CreateWedding::route('/create'),
            'view'   => Pages\ViewWedding::route('/{record}'),
            'edit'   => Pages\EditWedding::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'live')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }
}
