<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\SmartAlertResource\Pages;
use App\Models\SmartAlert;
use App\Models\Wedding;
use App\Services\SmartAlertService;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class SmartAlertResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = SmartAlert::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-exclamation-triangle';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 11;
    protected static ?string $recordTitleAttribute = 'title';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Alert')->columns(3)->schema([
                Infolists\Components\TextEntry::make('severity')->badge()->color(fn (string $state): string => match ($state) {
                    'critical' => 'danger',
                    'high' => 'warning',
                    'medium' => 'info',
                    default => 'gray',
                }),
                Infolists\Components\TextEntry::make('status')->badge()->color(fn (string $state): string => $state === 'active' ? 'warning' : 'success'),
                Infolists\Components\TextEntry::make('alert_type')->label('Type')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('target')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('trigger_at')->label('Due')->dateTime(),
                Infolists\Components\TextEntry::make('title')->columnSpanFull(),
                Infolists\Components\TextEntry::make('body')->columnSpanFull(),
                Infolists\Components\TextEntry::make('action_label')->label('Suggested action')->default('-'),
                Infolists\Components\TextEntry::make('action_url')->label('Action URL')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('resolved_at')->since()->placeholder('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Metadata')->schema([
                Infolists\Components\TextEntry::make('metadata')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('severity')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'critical' => 'danger',
                        'high' => 'warning',
                        'medium' => 'info',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'active' ? 'warning' : 'success'),
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->description(fn (SmartAlert $alert) => $alert->body)
                    ->limit(50),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('target')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('trigger_at')->label('Due')->since()->sortable(),
                Tables\Columns\TextColumn::make('resolved_at')->since()->placeholder('-')->toggleable(),
            ])
            ->defaultSort('trigger_at')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['active' => 'Active', 'resolved' => 'Resolved']),
                Tables\Filters\SelectFilter::make('severity')
                    ->options(['critical' => 'Critical', 'high' => 'High', 'medium' => 'Medium', 'low' => 'Low']),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->label('Wedding'),
            ])
            ->headerActions([
                Actions\Action::make('refreshAll')
                    ->label('Refresh all wedding alerts')
                    ->icon('heroicon-o-arrow-path')
                    ->color('info')
                    ->requiresConfirmation()
                    ->action(function (): void {
                        $weddings = Wedding::query()->get();
                        $activeCount = 0;

                        foreach ($weddings as $wedding) {
                            $activeCount += app(SmartAlertService::class)->refresh($wedding)->count();
                        }

                        Notification::make()
                            ->title("Refreshed {$activeCount} active alert(s) across {$weddings->count()} wedding(s)")
                            ->success()
                            ->send();
                    }),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\Action::make('resolve')
                    ->label('Resolve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn (SmartAlert $record) => $record->status === 'active')
                    ->action(function (SmartAlert $record): void {
                        $record->update([
                            'status' => 'resolved',
                            'resolved_at' => now(),
                        ]);

                        Notification::make()
                            ->title('Alert resolved')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSmartAlerts::route('/'),
            'view' => Pages\ViewSmartAlert::route('/{record}'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $active = static::getModel()::where('status', 'active')->count();
        return $active ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }
}
