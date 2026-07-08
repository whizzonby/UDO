<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SupportTicketResource\Pages;
use App\Models\SupportTicket;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class SupportTicketResource extends Resource
{
    protected static ?string $model = SupportTicket::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-lifebuoy';
    protected static string|\UnitEnum|null $navigationGroup = 'Support';
    protected static ?int $navigationSort = 1;
    protected static ?string $recordTitleAttribute = 'reference';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Ticket')->schema([
                Forms\Components\TextInput::make('reference')->disabled()->label('Reference'),
                Forms\Components\Select::make('status')
                    ->options([
                        'open'            => 'Open',
                        'in_progress'     => 'In progress',
                        'waiting_on_user' => 'Waiting on user',
                        'resolved'        => 'Resolved',
                        'closed'          => 'Closed',
                    ])
                    ->required(),
                Forms\Components\Select::make('priority')
                    ->options(['low' => 'Low', 'normal' => 'Normal', 'high' => 'High', 'urgent' => 'Urgent'])
                    ->required(),
                Forms\Components\Select::make('assigned_to')
                    ->relationship('assignee', 'email')
                    ->searchable()
                    ->nullable()
                    ->label('Assigned to'),
            ])->columns(2),
            \Filament\Schemas\Components\Section::make('Admin notes')->schema([
                Forms\Components\Textarea::make('admin_notes')->rows(4)->columnSpanFull()->label('Internal notes (not visible to user)'),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Ticket')->columns(3)->schema([
                Infolists\Components\TextEntry::make('reference')->copyable(),
                Infolists\Components\TextEntry::make('user.email')->label('User')->copyable(),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'in_progress'     => 'warning',
                        'waiting_on_user' => 'info',
                        'resolved'        => 'success',
                        'closed'          => 'danger',
                        default           => 'gray',
                    }),
                Infolists\Components\TextEntry::make('priority')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'normal'  => 'info',
                        'high'    => 'warning',
                        'urgent'  => 'danger',
                        default   => 'gray',
                    }),
                Infolists\Components\TextEntry::make('channel'),
                Infolists\Components\TextEntry::make('assignee.email')->label('Assigned to')->default('Unassigned'),
                Infolists\Components\TextEntry::make('created_at')->label('Opened')->since(),
                Infolists\Components\TextEntry::make('first_responded_at')->label('First response')->since()->default('—'),
                Infolists\Components\TextEntry::make('resolved_at')->label('Resolved')->since()->default('—'),
            ]),
            \Filament\Schemas\Components\Section::make('Message')->schema([
                Infolists\Components\TextEntry::make('subject')->label('Subject'),
                Infolists\Components\TextEntry::make('body')->label('Message')->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Admin notes')->schema([
                Infolists\Components\TextEntry::make('admin_notes')->default('No notes')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('reference')->copyable()->searchable()->sortable(),
                Tables\Columns\TextColumn::make('user.email')->label('User')->searchable(),
                Tables\Columns\TextColumn::make('subject')->limit(50)->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'in_progress'     => 'warning',
                        'waiting_on_user' => 'info',
                        'resolved'        => 'success',
                        'closed'          => 'danger',
                        default           => 'gray',
                    }),
                Tables\Columns\TextColumn::make('priority')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'normal'  => 'info',
                        'high'    => 'warning',
                        'urgent'  => 'danger',
                        default   => 'gray',
                    }),
                Tables\Columns\TextColumn::make('channel')
                    ->badge()
                    ->color('gray'),
                Tables\Columns\TextColumn::make('assignee.email')->label('Assigned')->default('—')->toggleable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['open' => 'Open', 'in_progress' => 'In progress', 'waiting_on_user' => 'Waiting', 'resolved' => 'Resolved', 'closed' => 'Closed']),
                Tables\Filters\SelectFilter::make('priority')
                    ->options(['low' => 'Low', 'normal' => 'Normal', 'high' => 'High', 'urgent' => 'Urgent']),
                Tables\Filters\Filter::make('unassigned')
                    ->query(fn ($query) => $query->whereNull('assigned_to'))
                    ->label('Unassigned only'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSupportTickets::route('/'),
            'view'  => Pages\ViewSupportTicket::route('/{record}'),
            'edit'  => Pages\EditSupportTicket::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $open = static::getModel()::whereIn('status', ['open', 'in_progress'])->count();
        return $open ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }
}
