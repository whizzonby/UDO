<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\InvitationCampaignResource\Pages;
use App\Models\Message;
use App\Services\MessageAnalyticsService;
use App\Services\MessageDispatchService;
use BackedEnum;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class InvitationCampaignResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = Message::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-envelope-open';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'campaign_name';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereIn('message_type', ['invitation', 'rsvp_reminder']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Campaign')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required()
                    ->label('Wedding'),
                Forms\Components\TextInput::make('campaign_name')->required()->maxLength(255),
                Forms\Components\Select::make('campaign_type')
                    ->options(['invitation' => 'Invitation', 'rsvp_reminder' => 'RSVP reminder'])
                    ->default('invitation')
                    ->required()
                    ->live()
                    ->afterStateUpdated(fn ($state, callable $set) => $set('message_type', $state)),
                Forms\Components\Hidden::make('message_type')->default('invitation'),
                Forms\Components\Select::make('channel')
                    ->options(['email' => 'Email', 'sms' => 'SMS', 'whatsapp' => 'WhatsApp'])
                    ->default('email')
                    ->required(),
                Forms\Components\Select::make('status')
                    ->options(['draft' => 'Draft', 'scheduled' => 'Scheduled', 'sending' => 'Sending', 'sent' => 'Sent', 'failed' => 'Failed'])
                    ->default('draft')
                    ->required(),
                Forms\Components\DateTimePicker::make('scheduled_at')->native(false),
                Forms\Components\TextInput::make('recipient_count')->numeric()->disabled()->dehydrated(false),
            ]),
            \Filament\Schemas\Components\Section::make('Copy')->schema([
                Forms\Components\TextInput::make('subject')->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('body')->required()->rows(6)->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Audience filter')->columns(3)->schema([
                Forms\Components\Select::make('audience_filter.attending_status')
                    ->options(['pending' => 'Pending', 'yes' => 'Attending', 'no' => 'Declined'])
                    ->label('RSVP status'),
                Forms\Components\TextInput::make('audience_filter.guest_group')->label('Guest group'),
                Forms\Components\TextInput::make('audience_filter.invite_status')->label('Invite status'),
                Forms\Components\Toggle::make('audience_filter.vip_flag')->label('VIP only'),
                Forms\Components\Toggle::make('audience_filter.has_email')->label('Must have email'),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Campaign')->columns(4)->schema([
                Infolists\Components\TextEntry::make('campaign_name')->label('Name'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('campaign_type')->badge()->color('info')->formatStateUsing(fn ($state) => $state === 'rsvp_reminder' ? 'RSVP reminder' : 'Invitation'),
                Infolists\Components\TextEntry::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'sent' => 'success',
                    'failed' => 'danger',
                    'sending' => 'warning',
                    'scheduled' => 'info',
                    default => 'gray',
                }),
                Infolists\Components\TextEntry::make('channel')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('recipient_count')->label('Recipients'),
                Infolists\Components\TextEntry::make('scheduled_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('sent_at')->since()->placeholder('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Delivery summary')->columns(4)->schema([
                Infolists\Components\TextEntry::make('delivery_total')
                    ->label('Total')
                    ->getStateUsing(fn (Message $campaign) => app(MessageAnalyticsService::class)->summaryFor($campaign)['total']),
                Infolists\Components\TextEntry::make('delivery_pending')
                    ->label('Pending')
                    ->getStateUsing(fn (Message $campaign) => app(MessageAnalyticsService::class)->summaryFor($campaign)['by_status']['pending'] ?? 0),
                Infolists\Components\TextEntry::make('delivery_sent')
                    ->label('Sent')
                    ->getStateUsing(fn (Message $campaign) => app(MessageAnalyticsService::class)->summaryFor($campaign)['by_status']['sent'] ?? 0),
                Infolists\Components\TextEntry::make('delivery_failed')
                    ->label('Failed')
                    ->getStateUsing(fn (Message $campaign) => app(MessageAnalyticsService::class)->summaryFor($campaign)['by_status']['failed'] ?? 0),
            ]),
            \Filament\Schemas\Components\Section::make('Copy')->schema([
                Infolists\Components\TextEntry::make('subject')->default('(no subject)'),
                Infolists\Components\TextEntry::make('body')->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Audience filter')->schema([
                Infolists\Components\TextEntry::make('audience_filter')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('campaign_name')->label('Campaign')->searchable()->limit(35),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('campaign_type')->badge()->formatStateUsing(fn ($state) => $state === 'rsvp_reminder' ? 'RSVP reminder' : 'Invitation'),
                Tables\Columns\TextColumn::make('channel')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('status')->badge()->color(fn (string $state): string => match ($state) {
                    'sent' => 'success',
                    'failed' => 'danger',
                    'sending' => 'warning',
                    'scheduled' => 'info',
                    default => 'gray',
                }),
                Tables\Columns\TextColumn::make('recipient_count')->label('Recipients')->sortable(),
                Tables\Columns\TextColumn::make('scheduled_at')->since()->placeholder('-')->sortable(),
                Tables\Columns\TextColumn::make('sent_at')->since()->placeholder('-')->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['draft' => 'Draft', 'scheduled' => 'Scheduled', 'sending' => 'Sending', 'sent' => 'Sent', 'failed' => 'Failed']),
                Tables\Filters\SelectFilter::make('campaign_type')
                    ->options(['invitation' => 'Invitation', 'rsvp_reminder' => 'RSVP reminder']),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->label('Wedding'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make()
                    ->visible(fn (Message $record) => ! in_array($record->status, ['sending', 'sent'], true)),
                Actions\Action::make('send')
                    ->label('Send now')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn (Message $record) => ! in_array($record->status, ['sending', 'sent'], true))
                    ->action(function (Message $record): void {
                        $recipients = app(MessageDispatchService::class)->dispatch($record->load('wedding'), true);

                        Notification::make()
                            ->title("Campaign queued for {$recipients} recipient(s)")
                            ->success()
                            ->send();
                    }),
                Actions\Action::make('retryFailed')
                    ->label('Retry failed')
                    ->icon('heroicon-o-arrow-path')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->visible(fn (Message $record) => $record->deliveries()->where('status', 'failed')->exists())
                    ->action(function (Message $record): void {
                        $queued = app(MessageDispatchService::class)->retryFailed($record);

                        Notification::make()
                            ->title("Queued {$queued} failed delivery retry/retries")
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInvitationCampaigns::route('/'),
            'create' => Pages\CreateInvitationCampaign::route('/create'),
            'view' => Pages\ViewInvitationCampaign::route('/{record}'),
            'edit' => Pages\EditInvitationCampaign::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $active = static::getModel()::whereIn('message_type', ['invitation', 'rsvp_reminder'])
            ->whereIn('status', ['draft', 'scheduled', 'failed'])
            ->count();

        return $active ?: null;
    }
}
