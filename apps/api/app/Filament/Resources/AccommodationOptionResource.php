<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\AccommodationOptionResource\Pages;
use App\Models\Guest;
use App\Models\AccommodationOption;
use App\Services\AdminLogisticsOpsService;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class AccommodationOptionResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = AccommodationOption::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-home-modern';
    protected static string|\UnitEnum|null $navigationGroup = 'Logistics';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Accommodation')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('type')
                    ->options(['hotel' => 'Hotel', 'bnb' => 'B&B', 'villa' => 'Villa', 'guesthouse' => 'Guesthouse', 'airbnb' => 'Airbnb'])
                    ->default('hotel')->required(),
                Forms\Components\TextInput::make('name')->required()->maxLength(255),
                Forms\Components\TextInput::make('city')->maxLength(100),
                Forms\Components\TextInput::make('country')->maxLength(100),
                Forms\Components\Textarea::make('address')->rows(2)->columnSpanFull(),
                Forms\Components\TextInput::make('price_per_night')->numeric()->prefix('$')->label('Price / night'),
                Forms\Components\TextInput::make('currency')->maxLength(3)->default('USD'),
                Forms\Components\TextInput::make('total_rooms_blocked')->numeric()->label('Rooms blocked'),
                Forms\Components\TextInput::make('booking_code')->maxLength(100)->label('Group code'),
                Forms\Components\TextInput::make('contact_name')->maxLength(255),
                Forms\Components\TextInput::make('contact_email')->email()->maxLength(255),
                Forms\Components\TextInput::make('contact_phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('website')->url()->maxLength(255),
                Forms\Components\TextInput::make('distance_from_venue_km')->numeric()->label('Distance from venue (km)'),
                Forms\Components\DatePicker::make('check_in_date')->native(false)->label('Check-in'),
                Forms\Components\DatePicker::make('check_out_date')->native(false)->label('Check-out'),
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
                Tables\Columns\TextColumn::make('city')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('price_per_night')->money('USD')->label('Price/night')->sortable(),
                Tables\Columns\TextColumn::make('rooms_assigned')->label('Assigned')
                    ->description(fn ($r) => $r->total_rooms_blocked ? "of {$r->total_rooms_blocked}" : null)
                    ->sortable(),
                Tables\Columns\TextColumn::make('check_in_date')->date()->label('Check-in')->sortable(),
                Tables\Columns\TextColumn::make('distance_from_venue_km')->label('km from venue')->sortable()->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options(['hotel' => 'Hotel', 'bnb' => 'B&B', 'villa' => 'Villa', 'guesthouse' => 'Guesthouse', 'airbnb' => 'Airbnb']),
            ])
            ->actions([static::assignGuestAction(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListAccommodationOptions::route('/'),
            'create' => Pages\CreateAccommodationOption::route('/create'),
            'edit'   => Pages\EditAccommodationOption::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Accommodation'; }

    public static function assignGuestAction(): Actions\Action
    {
        return Actions\Action::make('assignGuest')
            ->label('Assign guest')
            ->icon('heroicon-o-user-plus')
            ->form([
                Forms\Components\Select::make('guest_id')
                    ->label('Guest')
                    ->options(fn (AccommodationOption $record) => Guest::where('wedding_id', $record->wedding_id)->orderBy('first_name')->get()->mapWithKeys(fn (Guest $guest) => [$guest->id => $guest->full_name])->all())
                    ->searchable()
                    ->required(),
            ])
            ->action(function (AccommodationOption $record, array $data, AdminLogisticsOpsService $logisticsOps): void {
                $logisticsOps->assignAccommodation($record, Guest::findOrFail($data['guest_id']), auth()->user());
                Notification::make()->title('Guest assigned')->success()->send();
            });
    }
}
