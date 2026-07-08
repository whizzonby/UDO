<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TransportGroupResource\Pages;
use App\Models\TransportGroup;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class TransportGroupResource extends Resource
{
    protected static ?string $model = TransportGroup::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-truck';
    protected static string|\UnitEnum|null $navigationGroup = 'Logistics';
    protected static ?int $navigationSort = 3;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Transport')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('type')
                    ->options(['shuttle' => 'Shuttle', 'coach' => 'Coach', 'minibus' => 'Minibus', 'car' => 'Car', 'private' => 'Private'])
                    ->default('shuttle')->required(),
                Forms\Components\TextInput::make('name')->required()->maxLength(255)->placeholder('Airport Shuttle'),
                Forms\Components\TextInput::make('pickup_location')->maxLength(255)->label('Pick-up'),
                Forms\Components\TextInput::make('dropoff_location')->maxLength(255)->label('Drop-off'),
                Forms\Components\DateTimePicker::make('departure_time')->native(false)->label('Departure'),
                Forms\Components\TextInput::make('capacity')->numeric()->label('Capacity'),
                Forms\Components\TextInput::make('driver_name')->maxLength(255),
                Forms\Components\TextInput::make('driver_phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('vehicle_registration')->maxLength(50)->label('Reg. plate'),
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
                Tables\Columns\TextColumn::make('type')->badge()->color('info'),
                Tables\Columns\TextColumn::make('departure_time')->dateTime()->sortable()->label('Departure'),
                Tables\Columns\TextColumn::make('assigned_count')->label('Assigned')
                    ->description(fn ($r) => $r->capacity ? "of {$r->capacity}" : null)
                    ->sortable(),
                Tables\Columns\TextColumn::make('pickup_location')->label('Pick-up')->limit(30)->toggleable(),
                Tables\Columns\TextColumn::make('driver_name')->label('Driver')->toggleable(),
            ])
            ->defaultSort('departure_time', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options(['shuttle' => 'Shuttle', 'coach' => 'Coach', 'minibus' => 'Minibus', 'car' => 'Car']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListTransportGroups::route('/'),
            'create' => Pages\CreateTransportGroup::route('/create'),
            'edit'   => Pages\EditTransportGroup::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Transport'; }
}
