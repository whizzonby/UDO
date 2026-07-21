<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\LiveUpdateResource\Pages;
use App\Filament\Resources\LiveUpdateResource\RelationManagers;
use App\Models\LiveUpdate;
use App\Services\AdminLiveOpsService;
use Filament\Forms;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class LiveUpdateResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = LiveUpdate::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-signal';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 10;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Live update')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('type')
                    ->options([
                        'general' => 'General',
                        'schedule' => 'Schedule',
                        'venue' => 'Venue',
                        'announcement' => 'Announcement',
                        'incident' => 'Incident',
                        'alert' => 'Alert',
                        'vip' => 'VIP',
                        'arrival' => 'Arrival',
                        'logistics' => 'Logistics',
                    ])
                    ->default('general')->required(),
                Forms\Components\Select::make('audience')
                    ->options(['all' => 'All', 'guests' => 'Guests', 'team' => 'Team', 'vip' => 'VIP', 'private' => 'Private'])
                    ->default('all'),
                Forms\Components\TextInput::make('title')->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('body')->required()->rows(3)->columnSpanFull(),
                Forms\Components\TextInput::make('image_url')->url()->maxLength(2048)->columnSpanFull()->label('Image URL'),
                Forms\Components\DateTimePicker::make('event_time')->native(false)->label('Event time'),
                Forms\Components\Toggle::make('pinned')->label('Pinned'),
                Forms\Components\Toggle::make('visible_to_guests')->label('Visible to guests')->default(true),
                Forms\Components\Toggle::make('bride_only')->label('Planner only'),
                Forms\Components\Toggle::make('requires_action')->label('Requires action'),
                Forms\Components\Select::make('status')
                    ->options(['open' => 'Open', 'monitoring' => 'Monitoring', 'resolved' => 'Resolved'])
                    ->default('open'),
                Forms\Components\Select::make('severity')
                    ->options(['info' => 'Info', 'low' => 'Low', 'medium' => 'Medium', 'high' => 'High', 'critical' => 'Critical']),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Live update')->columns(3)->schema([
                Infolists\Components\TextEntry::make('title')->default('(untitled)'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('type')->badge(),
                Infolists\Components\TextEntry::make('severity')->badge()->default('-'),
                Infolists\Components\TextEntry::make('status')->badge()->default('open'),
                Infolists\Components\TextEntry::make('audience')->badge()->default('all'),
                Infolists\Components\IconEntry::make('requires_action')->boolean(),
                Infolists\Components\IconEntry::make('visible_to_guests')->boolean()->label('Guest visible'),
                Infolists\Components\IconEntry::make('pinned')->boolean(),
                Infolists\Components\TextEntry::make('resolved_at')->dateTime()->placeholder('-'),
                Infolists\Components\TextEntry::make('body')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->limit(40)->default('(untitled)'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('type')->badge()
                    ->color(fn ($s) => match ($s) {
                        'alert', 'incident' => 'danger',
                        'vip' => 'warning',
                        'announcement' => 'info',
                        'arrival', 'logistics' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('severity')->badge()
                    ->color(fn ($s) => match ($s) {
                        'critical' => 'danger', 'high' => 'warning', 'medium' => 'info', default => 'gray',
                    })
                    ->default('-'),
                Tables\Columns\TextColumn::make('status')->badge()
                    ->color(fn ($s) => match ($s) {
                        'resolved' => 'success', 'monitoring' => 'warning', default => 'gray',
                    })
                    ->default('open'),
                Tables\Columns\IconColumn::make('requires_action')->boolean()->label('Action'),
                Tables\Columns\IconColumn::make('pinned')->boolean()->label('Pinned'),
                Tables\Columns\IconColumn::make('visible_to_guests')->boolean()->label('Public'),
                Tables\Columns\TextColumn::make('event_time')->dateTime()->sortable()->label('Event time'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options([
                        'general' => 'General',
                        'schedule' => 'Schedule',
                        'venue' => 'Venue',
                        'announcement' => 'Announcement',
                        'incident' => 'Incident',
                        'alert' => 'Alert',
                        'vip' => 'VIP',
                        'arrival' => 'Arrival',
                        'logistics' => 'Logistics',
                    ]),
                Tables\Filters\SelectFilter::make('status')
                    ->options(['open' => 'Open', 'monitoring' => 'Monitoring', 'resolved' => 'Resolved']),
                Tables\Filters\TernaryFilter::make('visible_to_guests')->label('Guest visibility'),
                Tables\Filters\TernaryFilter::make('requires_action')->label('Requires action'),
            ])
            ->actions([Actions\ViewAction::make(), static::resolveAction(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\SubjectAuditLogsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListLiveUpdates::route('/'),
            'create' => Pages\CreateLiveUpdate::route('/create'),
            'view'   => Pages\ViewLiveUpdate::route('/{record}'),
            'edit'   => Pages\EditLiveUpdate::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Live Updates'; }

    public static function resolveAction(): Actions\Action
    {
        return Actions\Action::make('resolve')
            ->label('Resolve')
            ->icon('heroicon-o-check-circle')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (LiveUpdate $record) => ($record->status ?? 'open') !== 'resolved')
            ->action(function (LiveUpdate $record, AdminLiveOpsService $liveOps): void {
                $liveOps->resolveUpdate($record, auth()->user());
                Notification::make()->title('Live update resolved')->success()->send();
            });
    }
}
