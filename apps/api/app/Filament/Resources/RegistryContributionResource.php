<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\RegistryContributionResource\Pages;
use App\Filament\Resources\RegistryContributionResource\RelationManagers;
use App\Models\RegistryContribution;
use App\Services\AdminRegistryOpsService;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class RegistryContributionResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.finance';

    protected static ?string $model = RegistryContribution::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-banknotes';
    protected static string|UnitEnum|null $navigationGroup = 'Finance & Support';
    protected static ?int $navigationSort = 2;
    protected static ?string $navigationLabel = 'Registry Contributions';

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Contribution')->columns(3)->schema([
                Infolists\Components\TextEntry::make('item.name')->label('Item'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('guest.full_name')->label('Guest')->default('-'),
                Infolists\Components\TextEntry::make('contributor_name')->label('From'),
                Infolists\Components\TextEntry::make('contributor_email')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('amount')->money('usd'),
                Infolists\Components\TextEntry::make('quantity')->default('-'),
                Infolists\Components\TextEntry::make('payment_status')->badge(),
                Infolists\Components\IconEntry::make('thank_you_sent')->boolean()->label('Thank-you sent'),
                Infolists\Components\TextEntry::make('stripe_payment_intent_id')->copyable()->default('-')->columnSpanFull(),
                Infolists\Components\TextEntry::make('message')->default('-')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('item.name')->label('Item')->searchable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('guest.full_name')->label('Guest')->searchable()->default('-'),
                Tables\Columns\TextColumn::make('contributor_name')->label('From')->searchable(),
                Tables\Columns\TextColumn::make('amount')->money('usd')->sortable(),
                Tables\Columns\TextColumn::make('payment_status')->label('Status')->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'completed', 'succeeded' => 'success',
                        'failed' => 'danger',
                        'refunded' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('thank_you_sent')->boolean()->label('Thanks'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('payment_status')
                    ->options(['pending' => 'Pending', 'completed' => 'Completed', 'succeeded' => 'Succeeded', 'failed' => 'Failed', 'refunded' => 'Refunded']),
                Tables\Filters\TernaryFilter::make('thank_you_sent')->label('Thank-you sent'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                static::markPaidAction(),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ThankYouRecordRelationManager::class,
            RelationManagers\SubjectAuditLogsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRegistryContributions::route('/'),
            'view' => Pages\ViewRegistryContribution::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function markPaidAction(): Actions\Action
    {
        return Actions\Action::make('markPaid')
            ->label('Mark paid')
            ->icon('heroicon-o-check-circle')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (RegistryContribution $record) => ! in_array($record->payment_status, ['completed', 'succeeded'], true))
            ->action(function (RegistryContribution $record, AdminRegistryOpsService $registryOps): void {
                $registryOps->markContributionPaid($record, auth()->user());
                Notification::make()->title('Contribution marked paid')->success()->send();
            });
    }
}
