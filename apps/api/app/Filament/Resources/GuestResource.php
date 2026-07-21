<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GuestResource\Pages;
use App\Models\Guest;
use App\Services\AdminBulkOpsService;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;
use BackedEnum;
use UnitEnum;

class GuestResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.weddings';

    protected static ?string $model = Guest::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-user-group';
    protected static string|\UnitEnum|null $navigationGroup = 'Platform';
    protected static ?int $navigationSort = 3;
    protected static ?string $recordTitleAttribute = 'email';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Guest details')->columns(2)->schema([
                Forms\Components\TextInput::make('first_name')->required()->maxLength(100),
                Forms\Components\TextInput::make('last_name')->maxLength(100),
                Forms\Components\TextInput::make('email')->email()->maxLength(255),
                Forms\Components\TextInput::make('phone')->tel()->maxLength(30),
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required()
                    ->label('Wedding'),
            ]),
            \Filament\Schemas\Components\Section::make('RSVP & Status')->columns(2)->schema([
                Forms\Components\Select::make('attending_status')
                    ->options(['pending' => 'Pending', 'yes' => 'Attending', 'no' => 'Declined', 'maybe' => 'Maybe'])
                    ->default('pending'),
                Forms\Components\Select::make('rsvp_status')
                    ->options(['not_sent' => 'Not sent', 'sent' => 'Sent', 'opened' => 'Opened', 'responded' => 'Responded'])
                    ->default('not_sent'),
                Forms\Components\TextInput::make('meal_preference')->maxLength(100),
                Forms\Components\Toggle::make('plus_one_allowed')->label('Plus one'),
                Forms\Components\TextInput::make('table_number')->numeric(),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('first_name')
                    ->label('Guest')
                    ->description(fn (Guest $g) => $g->email)
                    ->searchable(['first_name', 'last_name', 'email'])
                    ->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('attending_status')
                    ->label('RSVP')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'yes'   => 'success',
                        'no'    => 'danger',
                        'maybe' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('rsvp_status')
                    ->label('Invite')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'sent'      => 'info',
                        'opened'    => 'warning',
                        'responded' => 'success',
                        default     => 'gray',
                    }),
                Tables\Columns\TextColumn::make('meal_preference')->label('Meal')->toggleable(),
                Tables\Columns\TextColumn::make('table_number')->label('Table')->toggleable(),
                Tables\Columns\IconColumn::make('plus_one_allowed')->boolean()->label('+1'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('attending_status')
                    ->options(['pending' => 'Pending', 'yes' => 'Attending', 'no' => 'Declined', 'maybe' => 'Maybe']),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->label('Wedding'),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    static::bulkUpdateAction(),
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListGuests::route('/'),
            'create' => Pages\CreateGuest::route('/create'),
            'edit'   => Pages\EditGuest::route('/{record}/edit'),
        ];
    }

    public static function bulkUpdateAction(): Actions\BulkAction
    {
        return Actions\BulkAction::make('bulkUpdate')
            ->label('Bulk update')
            ->icon('heroicon-o-pencil-square')
            ->color('warning')
            ->requiresConfirmation()
            ->modalDescription('Applies to every selected guest. All selected guests must belong to the same wedding.')
            ->schema([
                Forms\Components\Select::make('vip_flag')
                    ->label('VIP')
                    ->options(['1' => 'Mark as VIP', '0' => 'Remove VIP'])
                    ->placeholder('No change'),
                Forms\Components\TextInput::make('guest_group')
                    ->label('Guest group')
                    ->maxLength(100)
                    ->placeholder('No change'),
            ])
            ->action(function (Collection $records, array $data, AdminBulkOpsService $bulkOps): void {
                $updates = array_filter([
                    'vip_flag' => isset($data['vip_flag']) ? (bool) $data['vip_flag'] : null,
                    'guest_group' => filled($data['guest_group'] ?? null) ? $data['guest_group'] : null,
                ], fn ($value) => $value !== null);

                if (empty($updates)) {
                    Notification::make()->title('Nothing to update')->body('Choose at least one field to change.')->warning()->send();
                    return;
                }

                try {
                    $count = $bulkOps->applyUpdate('admin.guests_bulk_updated', $records, $updates, auth()->user());
                } catch (\RuntimeException $e) {
                    Notification::make()->title('Bulk update blocked')->body($e->getMessage())->danger()->send();
                    return;
                }

                Notification::make()->title("Updated {$count} guest(s)")->success()->send();
            });
    }
}
