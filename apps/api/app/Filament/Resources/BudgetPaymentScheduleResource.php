<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\BudgetPaymentScheduleResource\Pages;
use App\Filament\Resources\BudgetPaymentScheduleResource\RelationManagers;
use App\Models\BudgetPaymentSchedule;
use App\Services\AdminBudgetPaymentOpsService;
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

class BudgetPaymentScheduleResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = BudgetPaymentSchedule::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-calendar-days';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 13;
    protected static ?string $recordTitleAttribute = 'label';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Payment schedule')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required()
                    ->label('Wedding'),
                Forms\Components\Select::make('budget_item_id')
                    ->relationship('budgetItem', 'name')
                    ->searchable()
                    ->required()
                    ->label('Budget item'),
                Forms\Components\Select::make('vendor_id')
                    ->relationship('vendor', 'name')
                    ->searchable()
                    ->label('Vendor'),
                Forms\Components\TextInput::make('label')->required()->maxLength(255),
                Forms\Components\TextInput::make('amount')->numeric()->prefix('$')->default(0)->required(),
                Forms\Components\Select::make('status')
                    ->options(static::statusOptions())
                    ->default('pending')
                    ->required(),
                Forms\Components\DatePicker::make('due_date')->native(false)->label('Due date'),
                Forms\Components\DateTimePicker::make('paid_at')->native(false)->label('Paid at'),
                Forms\Components\DateTimePicker::make('reminder_at')->native(false)->label('Reminder at'),
                Forms\Components\Textarea::make('notes')->rows(3)->columnSpanFull(),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Payment')->columns(3)->schema([
                Infolists\Components\TextEntry::make('label'),
                Infolists\Components\TextEntry::make('amount')->money('usd'),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->formatStateUsing(fn ($state, BudgetPaymentSchedule $record) => app(AdminBudgetPaymentOpsService::class)->normalizedStatus($record))
                    ->color(fn ($state, BudgetPaymentSchedule $record) => static::statusColor(app(AdminBudgetPaymentOpsService::class)->normalizedStatus($record))),
                Infolists\Components\TextEntry::make('due_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('paid_at')->dateTime()->placeholder('-'),
                Infolists\Components\TextEntry::make('reminder_at')->dateTime()->placeholder('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Wedding and vendor')->columns(3)->schema([
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('budgetItem.name')->label('Budget item'),
                Infolists\Components\TextEntry::make('vendor.name')->label('Vendor')->default('-'),
                Infolists\Components\TextEntry::make('budgetItem.payment_status')->label('Item payment status')->badge(),
                Infolists\Components\TextEntry::make('budgetItem.paid_amount')->label('Item paid')->money('usd'),
                Infolists\Components\TextEntry::make('budgetItem.actual_amount')->label('Item actual')->money('usd'),
            ]),
            \Filament\Schemas\Components\Section::make('Notes')->schema([
                Infolists\Components\TextEntry::make('notes')->default('-')->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('label')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('budgetItem.name')->label('Budget item')->searchable(),
                Tables\Columns\TextColumn::make('vendor.name')->label('Vendor')->searchable()->default('-'),
                Tables\Columns\TextColumn::make('amount')->money('USD')->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn ($state, BudgetPaymentSchedule $record) => app(AdminBudgetPaymentOpsService::class)->normalizedStatus($record))
                    ->color(fn ($state, BudgetPaymentSchedule $record) => static::statusColor(app(AdminBudgetPaymentOpsService::class)->normalizedStatus($record))),
                Tables\Columns\TextColumn::make('due_date')->date()->sortable()->label('Due'),
                Tables\Columns\TextColumn::make('paid_at')->dateTime()->sortable()->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')->since()->sortable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('due_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')->options(static::statusOptions()),
                Tables\Filters\Filter::make('overdue')
                    ->query(fn (Builder $query) => $query
                        ->where('status', '!=', 'paid')
                        ->whereDate('due_date', '<', now()->toDateString())),
                Tables\Filters\Filter::make('due_next_30_days')
                    ->label('Due next 30 days')
                    ->query(fn (Builder $query) => $query
                        ->where('status', '!=', 'paid')
                        ->whereBetween('due_date', [now()->toDateString(), now()->addDays(30)->toDateString()])),
            ])
            ->actions([
                Actions\ViewAction::make(),
                static::markPaidAction(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([]);
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
            'index' => Pages\ListBudgetPaymentSchedules::route('/'),
            'create' => Pages\CreateBudgetPaymentSchedule::route('/create'),
            'view' => Pages\ViewBudgetPaymentSchedule::route('/{record}'),
            'edit' => Pages\EditBudgetPaymentSchedule::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string
    {
        return 'Budget Payments';
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', '!=', 'paid')
            ->whereDate('due_date', '<', now()->toDateString())
            ->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }

    public static function statusOptions(): array
    {
        return [
            'pending' => 'Pending',
            'scheduled' => 'Scheduled',
            'overdue' => 'Overdue',
            'paid' => 'Paid',
        ];
    }

    public static function statusColor(string $status): string
    {
        return match ($status) {
            'paid' => 'success',
            'overdue' => 'danger',
            'scheduled' => 'info',
            default => 'warning',
        };
    }

    public static function markPaidAction(): Actions\Action
    {
        return Actions\Action::make('markPaid')
            ->label('Mark paid')
            ->icon('heroicon-o-check-circle')
            ->color('success')
            ->requiresConfirmation()
            ->modalDescription('This marks the scheduled payment paid, updates the parent budget item balance, and writes an audit log.')
            ->visible(fn (BudgetPaymentSchedule $record) => $record->status !== 'paid')
            ->form([
                Forms\Components\Textarea::make('note')
                    ->label('Payment note')
                    ->maxLength(500)
                    ->helperText('Optional context such as receipt, bank reference, or admin reason.'),
            ])
            ->action(function (BudgetPaymentSchedule $record, array $data, AdminBudgetPaymentOpsService $paymentOps): void {
                $paymentOps->markPaid($record, auth()->user(), $data['note'] ?? null);

                Notification::make()
                    ->title('Payment marked paid')
                    ->success()
                    ->send();
            });
    }
}
