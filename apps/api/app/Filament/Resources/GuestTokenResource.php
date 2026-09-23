<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GuestTokenResource\Pages;
use App\Models\GuestToken;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

class GuestTokenResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = GuestToken::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-link';
    protected static string|UnitEnum|null $navigationGroup = 'Reliability & Ops';
    protected static ?int $navigationSort = 6;
    protected static ?string $recordTitleAttribute = 'token';

    /**
     * Tokens are created when couples send invitations; admins only inspect,
     * revoke/restore or extend them — never create or rewrite a guest's link.
     */
    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
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
                static::extendAction(),
                static::revokeAction(),
                static::restoreAction(),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListGuestTokens::route('/'),
            'view' => Pages\ViewGuestToken::route('/{record}'),
        ];
    }

    /** Push the expiry out 30 days (from now if already expired). */
    public static function extendAction(): Actions\Action
    {
        return Actions\Action::make('extend')
            ->label('Extend 30 days')
            ->icon('heroicon-o-clock')
            ->color('warning')
            ->requiresConfirmation()
            ->modalDescription("The guest's link will work for 30 more days.")
            ->visible(fn (GuestToken $record) => ! $record->revoked && $record->expires_at !== null)
            ->action(function (GuestToken $record): void {
                $from = $record->expires_at->isPast() ? now() : $record->expires_at;
                $record->update(['expires_at' => $from->copy()->addDays(30)]);
                Notification::make()
                    ->title('Link extended to ' . $record->expires_at->toFormattedDateString())
                    ->success()
                    ->send();
            });
    }

    public static function revokeAction(): Actions\Action
    {
        return Actions\Action::make('revoke')
            ->label('Revoke')
            ->icon('heroicon-o-x-circle')
            ->color('danger')
            ->requiresConfirmation()
            ->modalDescription("The guest's link stops working immediately.")
            ->visible(fn (GuestToken $record) => ! $record->revoked)
            ->action(function (GuestToken $record): void {
                $record->update(['revoked' => true]);
                Notification::make()->title('Guest token revoked')->success()->send();
            });
    }

    public static function restoreAction(): Actions\Action
    {
        return Actions\Action::make('restore')
            ->label('Restore')
            ->icon('heroicon-o-check-circle')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (GuestToken $record) => $record->revoked)
            ->action(function (GuestToken $record): void {
                $record->update(['revoked' => false]);
                Notification::make()->title('Guest token restored')->success()->send();
            });
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
