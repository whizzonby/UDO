<?php

namespace App\Filament\Resources;

use App\Filament\Resources\MessageResource\Pages;
use App\Models\Message;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class MessageResource extends Resource
{
    protected static ?string $model = Message::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 1;
    protected static ?string $recordTitleAttribute = 'subject';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Message')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('channel')
                    ->options(['email' => 'Email', 'sms' => 'SMS', 'whatsapp' => 'WhatsApp', 'push' => 'Push', 'in_app' => 'In-App'])
                    ->default('email')->required(),
                Forms\Components\Select::make('message_type')
                    ->options(['announcement' => 'Announcement', 'reminder' => 'Reminder', 'update' => 'Update', 'rsvp_nudge' => 'RSVP Nudge', 'thank_you' => 'Thank You'])
                    ->default('announcement')->required()->label('Type'),
                Forms\Components\Select::make('status')
                    ->options(['draft' => 'Draft', 'scheduled' => 'Scheduled', 'sending' => 'Sending', 'sent' => 'Sent', 'failed' => 'Failed'])
                    ->default('draft')->required(),
                Forms\Components\TextInput::make('subject')->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('body')->required()->rows(5)->columnSpanFull(),
                Forms\Components\DateTimePicker::make('scheduled_at')->label('Scheduled at')->native(false),
                Forms\Components\TextInput::make('recipient_count')->numeric()->default(0)->label('Recipients'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('subject')->searchable()->limit(40)->default('(no subject)'),
                Tables\Columns\TextColumn::make('message_type')->label('Type')->badge()
                    ->color(fn ($s) => match ($s) {
                        'announcement' => 'info', 'reminder' => 'warning',
                        'rsvp_nudge' => 'danger', 'thank_you' => 'success', default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('channel')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('status')->badge()
                    ->color(fn ($s) => match ($s) {
                        'sent' => 'success', 'failed' => 'danger',
                        'sending' => 'warning', 'scheduled' => 'info', default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('recipient_count')->label('Recipients')->sortable(),
                Tables\Columns\TextColumn::make('sent_at')->since()->label('Sent')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['draft' => 'Draft', 'scheduled' => 'Scheduled', 'sent' => 'Sent', 'failed' => 'Failed']),
                Tables\Filters\SelectFilter::make('channel')
                    ->options(['email' => 'Email', 'sms' => 'SMS', 'whatsapp' => 'WhatsApp']),
                Tables\Filters\SelectFilter::make('message_type')->label('Type')
                    ->options(['announcement' => 'Announcement', 'reminder' => 'Reminder', 'rsvp_nudge' => 'RSVP Nudge', 'thank_you' => 'Thank You']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListMessages::route('/'),
            'create' => Pages\CreateMessage::route('/create'),
            'edit'   => Pages\EditMessage::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'failed')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string { return 'danger'; }
}
