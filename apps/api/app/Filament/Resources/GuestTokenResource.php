<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GuestTokenResource\Pages;
use App\Models\GuestToken;
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

class GuestTokenResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = GuestToken::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-link';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 6;
    protected static ?string $recordTitleAttribute = 'token';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Token')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required(),
                Forms\Components\Select::make('guest_id')
                    ->relationship('guest', 'email')
                    ->searchable()
                    ->required(),
                Forms\Components\Select::make('view_type')
                    ->options([
                        'attending' => 'Attending',
                        'travelling' => 'Travelling',
                        'wedding_party' => 'Wedding party',
                        'pending' => 'Pending',
                    ])
                    ->default('attending')
                    ->required(),
                Forms\Components\DateTimePicker::make('expires_at')->native(false),
                Forms\Components\Toggle::make('revoked'),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Guest portal link')->columns(3)->schema([
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('guest.email')->label('Guest')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('view_type')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('token')->copyable()->columnSpanFull(),
                Infolists\Components\TextEntry::make('portal_url')
                    ->label('Portal URL')
                    ->getStateUsing(fn (GuestToken $token) => rtrim((string) config('app.frontend_url', config('app.url')), '/') . '/g/' . $token->token)
                    ->copyable()
                    ->columnSpanFull(),
                Infolists\Components\IconEntry::make('revoked')->boolean(),
                Infolists\Components\TextEntry::make('expires_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('validity')
                    ->label('Validity')
                    ->badge()
                    ->getStateUsing(fn (GuestToken $token) => $token->isValid() ? 'valid' : 'invalid')
                    ->color(fn (string $state): string => $state === 'valid' ? 'success' : 'danger'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('guest.email')->label('Guest')->searchable()->copyable()->default('-'),
                Tables\Columns\TextColumn::make('view_type')->badge()->color('gray'),
                Tables\Columns\IconColumn::make('revoked')->boolean(),
                Tables\Columns\TextColumn::make('expires_at')->since()->placeholder('-')->sortable(),
                Tables\Columns\TextColumn::make('token')->copyable()->limit(16),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('revoked'),
                Tables\Filters\SelectFilter::make('view_type')
                    ->options([
                        'attending' => 'Attending',
                        'travelling' => 'Travelling',
                        'wedding_party' => 'Wedding party',
                        'pending' => 'Pending',
                    ]),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable(),
                Tables\Filters\Filter::make('expired_active')
                    ->label('Expired but still active')
                    ->query(fn ($query) => $query->where('revoked', false)->whereNotNull('expires_at')->where('expires_at', '<', now())),
                Tables\Filters\Filter::make('expiring_soon')
                    ->label('Expiring within 7 days')
                    ->query(fn ($query) => $query->where('revoked', false)->whereBetween('expires_at', [now(), now()->addDays(7)])),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make(),
                Actions\Action::make('revoke')
                    ->label('Revoke')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn (GuestToken $record) => ! $record->revoked)
                    ->action(function (GuestToken $record): void {
                        $record->update(['revoked' => true]);
                        Notification::make()->title('Guest token revoked')->success()->send();
                    }),
                Actions\Action::make('restore')
                    ->label('Restore')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn (GuestToken $record) => $record->revoked)
                    ->action(function (GuestToken $record): void {
                        $record->update(['revoked' => false]);
                        Notification::make()->title('Guest token restored')->success()->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListGuestTokens::route('/'),
            'create' => Pages\CreateGuestToken::route('/create'),
            'view' => Pages\ViewGuestToken::route('/{record}'),
            'edit' => Pages\EditGuestToken::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $expired = static::getModel()::where('revoked', false)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<', now())
            ->count();

        return $expired ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }
}
