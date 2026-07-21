<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\SeatingTableResource\Pages;
use App\Models\SeatingTable;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class SeatingTableResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = SeatingTable::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-squares-2x2';
    protected static string|\UnitEnum|null $navigationGroup = 'Logistics';
    protected static ?int $navigationSort = 1;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Table')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\TextInput::make('name')->required()->maxLength(100)->placeholder('Table 1'),
                Forms\Components\Select::make('shape')
                    ->options(['round' => 'Round', 'rectangular' => 'Rectangular', 'oval' => 'Oval', 'custom' => 'Custom'])
                    ->default('round')->required(),
                Forms\Components\TextInput::make('capacity')->numeric()->required()->minValue(1),
                Forms\Components\TextInput::make('event_section')->maxLength(100)->placeholder('Main room, Garden...'),
                Forms\Components\TextInput::make('sort_order')->numeric()->default(0),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('shape')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('assigned_count')->label('Assigned')
                    ->description(fn ($r) => "of {$r->capacity}")
                    ->sortable(),
                Tables\Columns\TextColumn::make('capacity')->sortable(),
                Tables\Columns\TextColumn::make('event_section')->label('Section')->toggleable(),
                Tables\Columns\TextColumn::make('sort_order')->label('Order')->sortable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('sort_order', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->label('Wedding'),
                Tables\Filters\SelectFilter::make('shape')
                    ->options(['round' => 'Round', 'rectangular' => 'Rectangular', 'oval' => 'Oval']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListSeatingTables::route('/'),
            'create' => Pages\CreateSeatingTable::route('/create'),
            'edit'   => Pages\EditSeatingTable::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Seating'; }
}
