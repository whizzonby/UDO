<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\AuditLogResource\Pages;
use App\Models\AuditLog;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class AuditLogResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = AuditLog::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-list';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 15;
    protected static ?string $recordTitleAttribute = 'action';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Audit event')->columns(3)->schema([
                Infolists\Components\TextEntry::make('action')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding')->default('-'),
                Infolists\Components\TextEntry::make('user.email')->label('Actor')->copyable()->default('System'),
                Infolists\Components\TextEntry::make('auditable_type')->label('Record type')->formatStateUsing(fn (?string $state) => $state ? class_basename($state) : '-'),
                Infolists\Components\TextEntry::make('auditable_id')->label('Record ID')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('created_at')->label('When')->dateTime(),
                Infolists\Components\TextEntry::make('ip_address')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('user_agent')->columnSpan(2)->default('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Change data')->columns(3)->schema([
                Infolists\Components\TextEntry::make('before')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpan(1),
                Infolists\Components\TextEntry::make('after')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpan(1),
                Infolists\Components\TextEntry::make('metadata')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpan(1),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
                Tables\Columns\TextColumn::make('action')->searchable()->badge()->color('gray'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('user.email')->label('Actor')->searchable()->copyable()->default('System'),
                Tables\Columns\TextColumn::make('auditable_type')->label('Record')->formatStateUsing(fn (?string $state) => $state ? class_basename($state) : '-')->searchable(),
                Tables\Columns\TextColumn::make('auditable_id')->label('ID')->copyable()->toggleable(),
                Tables\Columns\TextColumn::make('ip_address')->copyable()->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->label('Wedding'),
                Tables\Filters\SelectFilter::make('user_id')
                    ->relationship('user', 'email')
                    ->searchable()
                    ->label('Actor'),
                Tables\Filters\Filter::make('created_at')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('from')->native(false),
                        \Filament\Forms\Components\DatePicker::make('until')->native(false),
                    ])
                    ->query(fn ($query, array $data) => $query
                        ->when($data['from'] ?? null, fn ($q, $date) => $q->whereDate('created_at', '>=', $date))
                        ->when($data['until'] ?? null, fn ($q, $date) => $q->whereDate('created_at', '<=', $date))),
            ])
            ->actions([
                Actions\ViewAction::make(),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAuditLogs::route('/'),
            'view' => Pages\ViewAuditLog::route('/{record}'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $today = static::getModel()::whereDate('created_at', now()->toDateString())->count();
        return $today ?: null;
    }
}
