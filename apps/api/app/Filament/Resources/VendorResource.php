<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\VendorResource\Pages;
use App\Filament\Resources\VendorResource\RelationManagers;
use App\Models\Vendor;
use App\Services\AdminBulkOpsService;
use App\Services\AdminVendorOpsService;
use Filament\Forms;
use Filament\Infolists;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;

class VendorResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = Vendor::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-building-storefront';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 7;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Vendor details')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals', 'music' => 'Music', 'hair_makeup' => 'Hair & Make-up', 'transport' => 'Transport', 'attire' => 'Attire', 'cake' => 'Cake', 'videography' => 'Videography', 'decor' => 'Decor', 'other' => 'Other'])
                    ->searchable()->required(),
                Forms\Components\TextInput::make('name')->required()->maxLength(255)->label('Business name'),
                Forms\Components\TextInput::make('contact_person')->maxLength(255),
                Forms\Components\TextInput::make('email')->email()->maxLength(255),
                Forms\Components\TextInput::make('phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('website')->url()->maxLength(255),
                Forms\Components\TextInput::make('instagram')->maxLength(100)->prefix('@'),
            ]),
            \Filament\Schemas\Components\Section::make('Financials & Status')->columns(2)->schema([
                Forms\Components\Select::make('booking_status')
                    ->options(static::statusOptions())
                    ->default('enquired')->required(),
                Forms\Components\Toggle::make('contract_signed')->label('Contract signed'),
                Forms\Components\TextInput::make('quoted_price')->numeric()->prefix('$'),
                Forms\Components\TextInput::make('deposit_paid')->numeric()->prefix('$')->default(0),
                Forms\Components\TextInput::make('balance_due')->numeric()->prefix('$')->default(0),
                Forms\Components\DatePicker::make('deposit_due_date')->native(false),
                Forms\Components\DatePicker::make('balance_due_date')->native(false),
                Forms\Components\Toggle::make('priority')->label('Priority vendor'),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Vendor operations')->columns(4)->schema([
                Infolists\Components\TextEntry::make('name')->label('Business'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('category')->badge(),
                Infolists\Components\TextEntry::make('risk')
                    ->label('Risk')
                    ->badge()
                    ->getStateUsing(fn (Vendor $vendor) => app(AdminVendorOpsService::class)->riskScore($vendor))
                    ->color(fn ($state) => match ($state) {
                        'attention' => 'danger',
                        'watch' => 'warning',
                        'cancelled' => 'gray',
                        default => 'success',
                    }),
                Infolists\Components\TextEntry::make('booking_status')->badge(),
                Infolists\Components\IconEntry::make('contract_signed')->boolean()->label('Contract'),
                Infolists\Components\TextEntry::make('contactLogs.0.follow_up_at')
                    ->label('Next follow-up')
                    ->getStateUsing(fn (Vendor $vendor) => $vendor->contactLogs()
                        ->whereNotNull('follow_up_at')
                        ->where('follow_up_at', '>=', now())
                        ->orderBy('follow_up_at')
                        ->value('follow_up_at')?->toDayDateTimeString() ?: '-'),
                Infolists\Components\TextEntry::make('open_tasks')
                    ->label('Open tasks')
                    ->getStateUsing(fn (Vendor $vendor) => $vendor->tasks()->where('completed', false)->count()),
            ]),
            \Filament\Schemas\Components\Section::make('Contact')->columns(3)->schema([
                Infolists\Components\TextEntry::make('contact_person')->default('-'),
                Infolists\Components\TextEntry::make('email')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('phone')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('website')->url(fn ($state) => $state)->default('-'),
                Infolists\Components\TextEntry::make('instagram')->default('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Financials')->columns(3)->schema([
                Infolists\Components\TextEntry::make('quoted_price')->money('usd')->label('Quote'),
                Infolists\Components\TextEntry::make('deposit_paid')->money('usd')->label('Deposit paid'),
                Infolists\Components\TextEntry::make('balance_due')->money('usd')->label('Balance due'),
                Infolists\Components\TextEntry::make('deposit_due_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('balance_due_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('contract_file_url')->copyable()->default('-'),
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
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('category')->badge()->color('info'),
                Tables\Columns\TextColumn::make('risk')
                    ->label('Risk')
                    ->badge()
                    ->getStateUsing(fn (Vendor $vendor) => app(AdminVendorOpsService::class)->riskScore($vendor))
                    ->color(fn ($state) => match ($state) {
                        'attention' => 'danger',
                        'watch' => 'warning',
                        'cancelled' => 'gray',
                        default => 'success',
                    }),
                Tables\Columns\TextColumn::make('booking_status')->label('Status')->badge()
                    ->color(fn ($s) => match ($s) {
                        'booked', 'confirmed' => 'info', 'paid' => 'success',
                        'cancelled' => 'danger', 'shortlisted' => 'warning', default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('contract_signed')->boolean()->label('Contract'),
                Tables\Columns\TextColumn::make('quoted_price')->money('USD')->sortable()->label('Quote'),
                Tables\Columns\TextColumn::make('balance_due')->money('USD')->sortable()->label('Balance'),
                Tables\Columns\TextColumn::make('contact_person')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('email')->searchable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('booking_status')->label('Status')
                    ->options(static::statusOptions()),
                Tables\Filters\SelectFilter::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals', 'music' => 'Music']),
                Tables\Filters\TernaryFilter::make('contract_signed')->label('Contract signed'),
            ])
            ->actions([Actions\ViewAction::make(), static::logContactAction(), static::markContractSignedAction(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    static::bulkUpdateAction(),
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ContactLogsRelationManager::class,
            RelationManagers\TasksRelationManager::class,
            RelationManagers\BudgetItemsRelationManager::class,
            RelationManagers\SubjectAuditLogsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListVendors::route('/'),
            'create' => Pages\CreateVendor::route('/create'),
            'view'   => Pages\ViewVendor::route('/{record}'),
            'edit'   => Pages\EditVendor::route('/{record}/edit'),
        ];
    }

    public static function statusOptions(): array
    {
        return [
            'enquired' => 'Enquired',
            'researching' => 'Researching',
            'shortlisted' => 'Shortlisted',
            'negotiating' => 'Negotiating',
            'booked' => 'Booked',
            'confirmed' => 'Confirmed',
            'paid' => 'Paid',
            'cancelled' => 'Cancelled',
        ];
    }

    public static function logContactAction(): Actions\Action
    {
        return Actions\Action::make('logContact')
            ->label('Log contact')
            ->icon('heroicon-o-chat-bubble-left-right')
            ->form([
                Forms\Components\Select::make('contact_type')
                    ->options(['email' => 'Email', 'call' => 'Call', 'sms' => 'SMS', 'meeting' => 'Meeting', 'note' => 'Note'])
                    ->default('note')
                    ->required(),
                Forms\Components\TextInput::make('subject')->required()->maxLength(255),
                Forms\Components\Textarea::make('body')->rows(3),
                Forms\Components\TextInput::make('outcome')->maxLength(255),
                Forms\Components\DateTimePicker::make('contact_at')->native(false)->default(now()),
                Forms\Components\DateTimePicker::make('follow_up_at')->native(false),
            ])
            ->action(function (Vendor $record, array $data, AdminVendorOpsService $vendorOps): void {
                $vendorOps->logContact($record, auth()->user(), $data);

                Notification::make()->title('Contact logged')->success()->send();
            });
    }

    public static function markContractSignedAction(): Actions\Action
    {
        return Actions\Action::make('markContractSigned')
            ->label('Mark contract signed')
            ->icon('heroicon-o-document-check')
            ->color('success')
            ->requiresConfirmation()
            ->visible(fn (Vendor $record) => ! $record->contract_signed)
            ->form([
                Forms\Components\TextInput::make('contract_file_url')->label('Contract URL')->url()->maxLength(500),
            ])
            ->action(function (Vendor $record, array $data, AdminVendorOpsService $vendorOps): void {
                $vendorOps->markContractSigned($record, auth()->user(), $data['contract_file_url'] ?? null);

                Notification::make()->title('Contract marked signed')->success()->send();
            });
    }

    public static function bulkUpdateAction(): Actions\BulkAction
    {
        return Actions\BulkAction::make('bulkUpdate')
            ->label('Bulk update')
            ->icon('heroicon-o-pencil-square')
            ->color('warning')
            ->requiresConfirmation()
            ->modalDescription('Applies to every selected vendor. All selected vendors must belong to the same wedding.')
            ->schema([
                Forms\Components\Select::make('booking_status')
                    ->label('Status')
                    ->options(static::statusOptions())
                    ->placeholder('No change'),
                Forms\Components\Select::make('contract_signed')
                    ->label('Contract signed')
                    ->options(['1' => 'Yes', '0' => 'No'])
                    ->placeholder('No change'),
            ])
            ->action(function (Collection $records, array $data, AdminBulkOpsService $bulkOps): void {
                $updates = array_filter([
                    'booking_status' => filled($data['booking_status'] ?? null) ? $data['booking_status'] : null,
                    'contract_signed' => isset($data['contract_signed']) ? (bool) $data['contract_signed'] : null,
                ], fn ($value) => $value !== null);

                if (empty($updates)) {
                    Notification::make()->title('Nothing to update')->body('Choose at least one field to change.')->warning()->send();
                    return;
                }

                try {
                    $count = $bulkOps->applyUpdate('admin.vendors_bulk_updated', $records, $updates, auth()->user());
                } catch (\RuntimeException $e) {
                    Notification::make()->title('Bulk update blocked')->body($e->getMessage())->danger()->send();
                    return;
                }

                Notification::make()->title("Updated {$count} vendor(s)")->success()->send();
            });
    }
}
