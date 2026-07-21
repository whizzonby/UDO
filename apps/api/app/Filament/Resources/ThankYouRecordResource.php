<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\ThankYouRecordResource\Pages;
use App\Models\ThankYouRecord;
use App\Services\AdminRegistryOpsService;
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

class ThankYouRecordResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.finance';

    protected static ?string $model = ThankYouRecord::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-envelope';
    protected static string|UnitEnum|null $navigationGroup = 'Finance & Support';
    protected static ?int $navigationSort = 3;
    protected static ?string $navigationLabel = 'Thank-Yous';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\Select::make('status')->options(['pending' => 'Pending', 'drafted' => 'Drafted', 'sent' => 'Sent'])->required(),
            Forms\Components\Select::make('channel')->options(['email' => 'Email', 'sms' => 'SMS', 'card' => 'Card', 'manual' => 'Manual']),
            Forms\Components\Textarea::make('note')->rows(4)->columnSpanFull(),
            Forms\Components\DateTimePicker::make('sent_at')->native(false),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Thank-you')->columns(3)->schema([
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('recipient_name'),
                Infolists\Components\TextEntry::make('recipient_email')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('reason')->badge(),
                Infolists\Components\TextEntry::make('status')->badge(),
                Infolists\Components\TextEntry::make('channel')->badge()->default('-'),
                Infolists\Components\TextEntry::make('sent_at')->dateTime()->placeholder('-'),
                Infolists\Components\TextEntry::make('contribution.amount')->money('usd')->label('Contribution')->default('-'),
                Infolists\Components\TextEntry::make('note')->columnSpanFull()->default('-'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('recipient_name')->searchable(),
                Tables\Columns\TextColumn::make('reason')->badge(),
                Tables\Columns\TextColumn::make('status')->badge()
                    ->color(fn (string $state): string => $state === 'sent' ? 'success' : 'warning'),
                Tables\Columns\TextColumn::make('channel')->badge()->default('-'),
                Tables\Columns\TextColumn::make('sent_at')->dateTime()->sortable()->placeholder('-'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')->options(['pending' => 'Pending', 'drafted' => 'Drafted', 'sent' => 'Sent']),
            ])
            ->actions([
                Actions\ViewAction::make(),
                static::markSentAction(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListThankYouRecords::route('/'),
            'view' => Pages\ViewThankYouRecord::route('/{record}'),
            'edit' => Pages\EditThankYouRecord::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', '!=', 'sent')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function markSentAction(): Actions\Action
    {
        return Actions\Action::make('markSent')
            ->label('Mark sent')
            ->icon('heroicon-o-paper-airplane')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (ThankYouRecord $record) => $record->status !== 'sent')
            ->form([
                Forms\Components\Select::make('channel')->options(['email' => 'Email', 'sms' => 'SMS', 'card' => 'Card', 'manual' => 'Manual'])->default('email')->required(),
                Forms\Components\Textarea::make('note')->rows(4)->maxLength(2000),
            ])
            ->action(function (ThankYouRecord $record, array $data, AdminRegistryOpsService $registryOps): void {
                $registryOps->markThankYouSent($record, auth()->user(), $data['note'] ?? null, $data['channel'] ?? null);
                Notification::make()->title('Thank-you marked sent')->success()->send();
            });
    }
}
