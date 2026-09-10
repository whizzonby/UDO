<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;
use App\Filament\Resources\InsurancePolicyResource\Pages;
use App\Models\InsurancePolicy;
use BackedEnum;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class InsurancePolicyResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = InsurancePolicy::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-shield-check';
    protected static string|UnitEnum|null $navigationGroup = 'Wedding Data';
    protected static ?string $recordTitleAttribute = 'policy_number';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Policy')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->required()
                    ->label('Wedding'),
                Forms\Components\TextInput::make('provider')->required()->maxLength(255),
                Forms\Components\TextInput::make('policy_number')->required()->maxLength(100),
                Forms\Components\Select::make('policy_type')
                    ->options([
                        'liability' => 'Liability',
                        'cancellation' => 'Cancellation',
                        'weather' => 'Weather',
                        'combined' => 'Combined',
                    ])
                    ->required(),
                Forms\Components\Select::make('status')
                    ->options([
                        'active' => 'Active',
                        'pending' => 'Pending',
                        'expired' => 'Expired',
                        'cancelled' => 'Cancelled',
                    ])
                    ->default('pending')
                    ->required(),
            ]),
            \Filament\Schemas\Components\Section::make('Coverage')->columns(3)->schema([
                Forms\Components\TextInput::make('coverage_amount')->numeric()->prefix('$'),
                Forms\Components\TextInput::make('premium_amount')->numeric()->prefix('$'),
                Forms\Components\TextInput::make('deductible_amount')->numeric()->prefix('$'),
                Forms\Components\DatePicker::make('purchase_date')->native(false),
                Forms\Components\DatePicker::make('start_date')->native(false),
                Forms\Components\DatePicker::make('end_date')->native(false),
            ]),
            \Filament\Schemas\Components\Section::make('Contact')->columns(3)->schema([
                Forms\Components\TextInput::make('contact_name')->maxLength(255),
                Forms\Components\TextInput::make('contact_phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('claim_phone')->tel()->maxLength(30),
                Forms\Components\Textarea::make('notes')->columnSpanFull()->rows(3),
            ]),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Policy')->columns(3)->schema([
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('provider'),
                Infolists\Components\TextEntry::make('policy_number')->copyable(),
                Infolists\Components\TextEntry::make('policy_type')->badge(),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'pending' => 'warning',
                        'cancelled', 'expired' => 'danger',
                        default => 'gray',
                    }),
                Infolists\Components\TextEntry::make('coverage_amount')->money('usd')->default('-'),
                Infolists\Components\TextEntry::make('premium_amount')->money('usd')->default('-'),
                Infolists\Components\TextEntry::make('deductible_amount')->money('usd')->default('-'),
                Infolists\Components\TextEntry::make('purchase_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('start_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('end_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('contact_name')->label('Contact')->default('-'),
                Infolists\Components\TextEntry::make('contact_phone')->label('Contact phone')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('claim_phone')->label('Claim phone')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('notes')->columnSpanFull()->default('-'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('provider')->searchable(),
                Tables\Columns\TextColumn::make('policy_number')->copyable()->searchable(),
                Tables\Columns\TextColumn::make('policy_type')->badge(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'pending' => 'warning',
                        'cancelled', 'expired' => 'danger',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('coverage_amount')->money('usd')->sortable(),
                Tables\Columns\TextColumn::make('end_date')->date()->label('Expires')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['active' => 'Active', 'pending' => 'Pending', 'expired' => 'Expired', 'cancelled' => 'Cancelled']),
                Tables\Filters\SelectFilter::make('policy_type')
                    ->options(['liability' => 'Liability', 'cancellation' => 'Cancellation', 'weather' => 'Weather', 'combined' => 'Combined']),
            ])
            ->actions([Actions\ViewAction::make(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([
                Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInsurancePolicies::route('/'),
            'create' => Pages\CreateInsurancePolicy::route('/create'),
            'view' => Pages\ViewInsurancePolicy::route('/{record}'),
            'edit' => Pages\EditInsurancePolicy::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'active')->count() ?: null;
    }
}
