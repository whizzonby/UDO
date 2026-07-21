<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\FailedJobResource\Pages;
use App\Models\FailedJob;
use App\Services\AdminReliabilityOpsService;
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

class FailedJobResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = FailedJob::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-exclamation-triangle';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 18;
    protected static ?string $recordTitleAttribute = 'uuid';

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
            \Filament\Schemas\Components\Section::make('Failed job')->columns(3)->schema([
                Infolists\Components\TextEntry::make('displayName')
                    ->label('Job')
                    ->getStateUsing(fn (FailedJob $job) => $job->jobClass()),
                Infolists\Components\TextEntry::make('connection'),
                Infolists\Components\TextEntry::make('queue'),
                Infolists\Components\TextEntry::make('uuid')->copyable()->columnSpanFull(),
                Infolists\Components\TextEntry::make('failed_at')->dateTime(),
            ]),
            \Filament\Schemas\Components\Section::make('Exception')->schema([
                Infolists\Components\TextEntry::make('exception')->label('')->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Payload')->schema([
                Infolists\Components\TextEntry::make('payload')
                    ->label('')
                    ->formatStateUsing(fn (string $state) => json_encode(json_decode($state, true), JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('displayName')
                    ->label('Job')
                    ->getStateUsing(fn (FailedJob $job) => $job->jobClass())
                    ->searchable(query: fn ($query, string $search) => $query->where('payload', 'like', "%{$search}%")),
                Tables\Columns\TextColumn::make('connection')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('queue')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('exceptionSummary')
                    ->label('Exception')
                    ->getStateUsing(fn (FailedJob $job) => $job->exceptionSummary())
                    ->limit(80),
                Tables\Columns\TextColumn::make('failed_at')->since()->sortable(),
            ])
            ->defaultSort('failed_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('queue')
                    ->options(fn () => FailedJob::query()->distinct()->pluck('queue', 'queue')->all()),
            ])
            ->actions([
                Actions\ViewAction::make(),
                static::retryAction(),
                static::forgetAction(),
            ])
            ->bulkActions([])
            ->emptyStateHeading('No failed jobs')
            ->emptyStateDescription('The queue is healthy — nothing has failed since it was last cleared.')
            ->emptyStateIcon('heroicon-o-check-circle');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListFailedJobs::route('/'),
            'view' => Pages\ViewFailedJob::route('/{record}'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }

    public static function retryAction(): Actions\Action
    {
        return Actions\Action::make('retry')
            ->label('Retry')
            ->icon('heroicon-o-arrow-path')
            ->color('warning')
            ->requiresConfirmation()
            ->action(function (FailedJob $record, AdminReliabilityOpsService $reliabilityOps): void {
                $reliabilityOps->retryFailedJob($record, auth()->user());
                Notification::make()->title('Job pushed back onto the queue')->success()->send();
            });
    }

    public static function forgetAction(): Actions\Action
    {
        return Actions\Action::make('forget')
            ->label('Delete')
            ->icon('heroicon-o-trash')
            ->color('danger')
            ->requiresConfirmation()
            ->modalDescription('This permanently discards the failed job. It will not be retried.')
            ->action(function (FailedJob $record, AdminReliabilityOpsService $reliabilityOps): void {
                $reliabilityOps->forgetFailedJob($record, auth()->user());
                Notification::make()->title('Failed job deleted')->success()->send();
            });
    }
}
