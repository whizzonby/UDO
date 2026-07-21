<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\GuestMessageDeliveryResource\Pages;
use App\Jobs\SendGuestMessageDeliveryJob;
use App\Models\GuestMessageDelivery;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class GuestMessageDeliveryResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = GuestMessageDelivery::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-paper-airplane';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 4;
    protected static ?string $navigationLabel = 'Message Deliveries';
    protected static ?string $recordTitleAttribute = 'external_id';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Delivery')->columns(3)->schema([
                Infolists\Components\TextEntry::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'sent', 'delivered' => 'success',
                    'failed' => 'danger',
                    'pending', 'queued' => 'warning',
                    default => 'gray',
                }),
                Infolists\Components\TextEntry::make('channel')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('external_id')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('message.subject')->label('Message')->default('(no subject)'),
                Infolists\Components\TextEntry::make('message.wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('guest.email')->label('Guest email')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('sent_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('delivered_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('opened_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('error_message')->columnSpanFull()->default('-'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'sent', 'delivered' => 'success',
                    'failed' => 'danger',
                    'pending', 'queued' => 'warning',
                    default => 'gray',
                }),
                Tables\Columns\TextColumn::make('channel')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('message.wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('message.subject')->label('Message')->searchable()->limit(40)->default('(no subject)'),
                Tables\Columns\TextColumn::make('guest.email')->label('Guest')->searchable()->copyable()->default('-'),
                Tables\Columns\TextColumn::make('external_id')->copyable()->toggleable(),
                Tables\Columns\TextColumn::make('error_message')->limit(45)->toggleable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'sent' => 'Sent',
                        'delivered' => 'Delivered',
                        'failed' => 'Failed',
                    ]),
                Tables\Filters\SelectFilter::make('channel')
                    ->options(['email' => 'Email', 'sms' => 'SMS', 'whatsapp' => 'WhatsApp']),
                Tables\Filters\SelectFilter::make('message_id')
                    ->relationship('message', 'subject')
                    ->searchable()
                    ->label('Message'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\Action::make('retry')
                    ->label('Retry')
                    ->icon('heroicon-o-arrow-path')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->visible(fn (GuestMessageDelivery $record) => $record->status === 'failed')
                    ->action(function (GuestMessageDelivery $record): void {
                        $record->update([
                            'status' => 'pending',
                            'external_id' => null,
                            'sent_at' => null,
                            'delivered_at' => null,
                            'opened_at' => null,
                            'error_message' => null,
                        ]);
                        $record->message?->update(['status' => 'sending']);

                        SendGuestMessageDeliveryJob::dispatch($record->id);

                        Notification::make()
                            ->title('Delivery retry queued')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListGuestMessageDeliveries::route('/'),
            'view' => Pages\ViewGuestMessageDelivery::route('/{record}'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $failed = static::getModel()::where('status', 'failed')->count();
        return $failed ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }
}
