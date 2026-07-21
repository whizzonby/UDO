<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\TimelineItemResource\Pages;
use App\Models\TimelineItem;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class TimelineItemResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = TimelineItem::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clock';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 14;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Timeline item')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('event_type')
                    ->options(['ceremony' => 'Ceremony', 'reception' => 'Reception', 'pre-wedding' => 'Pre-wedding', 'post-wedding' => 'Post-wedding', 'custom' => 'Custom'])
                    ->default('ceremony')->required()->label('Event type'),
                Forms\Components\TextInput::make('title')->required()->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('description')->rows(2)->columnSpanFull(),
                Forms\Components\DatePicker::make('event_date')->native(false)->label('Date'),
                Forms\Components\TimePicker::make('start_time')->native(false)->label('Start'),
                Forms\Components\TimePicker::make('end_time')->native(false)->label('End'),
                Forms\Components\TextInput::make('duration_minutes')->numeric()->label('Duration (min)'),
                Forms\Components\TextInput::make('location')->maxLength(255)->columnSpanFull(),
                Forms\Components\TextInput::make('location_address')->maxLength(500)->columnSpanFull()->label('Address'),
                Forms\Components\Toggle::make('visible_to_guests')->label('Visible to guests')->default(true),
                Forms\Components\TextInput::make('sort_order')->numeric()->default(0),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('event_type')->label('Type')->badge()->color('info'),
                Tables\Columns\TextColumn::make('event_date')->date()->sortable()->label('Date'),
                Tables\Columns\TextColumn::make('start_time')->label('Start')->sortable(),
                Tables\Columns\TextColumn::make('end_time')->label('End')->sortable(),
                Tables\Columns\TextColumn::make('location')->limit(30)->toggleable(),
                Tables\Columns\IconColumn::make('visible_to_guests')->boolean()->label('Public'),
            ])
            ->defaultSort('event_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('event_type')->label('Type')
                    ->options(['ceremony' => 'Ceremony', 'reception' => 'Reception', 'pre-wedding' => 'Pre-wedding', 'post-wedding' => 'Post-wedding', 'custom' => 'Custom']),
                Tables\Filters\TernaryFilter::make('visible_to_guests')->label('Guest visibility'),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListTimelineItems::route('/'),
            'create' => Pages\CreateTimelineItem::route('/create'),
            'edit'   => Pages\EditTimelineItem::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Timeline'; }
}
