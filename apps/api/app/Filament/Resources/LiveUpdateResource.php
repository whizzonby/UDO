<?php

namespace App\Filament\Resources;

use App\Filament\Resources\LiveUpdateResource\Pages;
use App\Models\LiveUpdate;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class LiveUpdateResource extends Resource
{
    protected static ?string $model = LiveUpdate::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-signal';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 5;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Live update')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('type')
                    ->options(['announcement' => 'Announcement', 'moment' => 'Moment', 'alert' => 'Alert', 'photo' => 'Photo', 'location_update' => 'Location Update'])
                    ->default('announcement')->required(),
                Forms\Components\TextInput::make('title')->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('body')->required()->rows(3)->columnSpanFull(),
                Forms\Components\TextInput::make('image_url')->url()->maxLength(2048)->columnSpanFull()->label('Image URL'),
                Forms\Components\DateTimePicker::make('event_time')->native(false)->label('Event time'),
                Forms\Components\Toggle::make('pinned')->label('Pinned'),
                Forms\Components\Toggle::make('visible_to_guests')->label('Visible to guests')->default(true),
                Forms\Components\Toggle::make('bride_only')->label('Planner only'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->limit(40)->default('(untitled)'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('type')->badge()
                    ->color(fn ($s) => match ($s) {
                        'alert' => 'danger', 'announcement' => 'info',
                        'moment' => 'success', 'photo' => 'warning', default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('pinned')->boolean()->label('Pinned'),
                Tables\Columns\IconColumn::make('visible_to_guests')->boolean()->label('Public'),
                Tables\Columns\TextColumn::make('event_time')->dateTime()->sortable()->label('Event time'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options(['announcement' => 'Announcement', 'moment' => 'Moment', 'alert' => 'Alert', 'photo' => 'Photo']),
                Tables\Filters\TernaryFilter::make('visible_to_guests')->label('Guest visibility'),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListLiveUpdates::route('/'),
            'create' => Pages\CreateLiveUpdate::route('/create'),
            'edit'   => Pages\EditLiveUpdate::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Live Updates'; }
}
