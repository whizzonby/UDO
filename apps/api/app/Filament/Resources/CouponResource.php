<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;
use App\Filament\Resources\CouponResource\Pages;
use App\Filament\Resources\CouponResource\RelationManagers;
use App\Models\Coupon;
use BackedEnum;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class CouponResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.finance';

    protected static ?string $model = Coupon::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-ticket';
    protected static string|UnitEnum|null $navigationGroup = 'Finance & Support';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'code';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('code')
                ->required()
                ->maxLength(40)
                ->unique(ignoreRecord: true)
                ->helperText('Shown to users at checkout, e.g. WEDDING20. Stored uppercase.'),
            Forms\Components\Select::make('type')
                ->options(['percent' => 'Percent off', 'fixed' => 'Fixed amount off (cents)'])
                ->default('percent')
                ->required()
                ->live(),
            Forms\Components\TextInput::make('value')
                ->numeric()
                ->required()
                ->minValue(1)
                ->suffix(fn (Get $get) => $get('type') === 'percent' ? '%' : 'cents')
                ->helperText(fn (Get $get) => $get('type') === 'percent'
                    ? 'Whole number 1-100.'
                    : 'Amount off in cents, e.g. 1000 = $10.00 off.'),
            Forms\Components\TextInput::make('max_redemptions')
                ->numeric()
                ->minValue(1)
                ->label('Max redemptions')
                ->helperText('Leave blank for unlimited.'),
            Forms\Components\DateTimePicker::make('expires_at')
                ->native(false)
                ->label('Expires at')
                ->helperText('Leave blank for no expiry.'),
            Forms\Components\Select::make('status')
                ->options(['active' => 'Active', 'disabled' => 'Disabled'])
                ->default('active')
                ->required(),
            Forms\Components\Textarea::make('note')
                ->maxLength(500)
                ->columnSpanFull()
                ->helperText('Internal note — why this code exists / who it is for.'),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Coupon')->columns(3)->schema([
                Infolists\Components\TextEntry::make('code')->copyable(),
                Infolists\Components\TextEntry::make('type')->badge(),
                Infolists\Components\TextEntry::make('value')
                    ->label('Value')
                    ->getStateUsing(fn (Coupon $coupon) => static::valueLabel($coupon)),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state) => $state === 'active' ? 'success' : 'gray'),
                Infolists\Components\TextEntry::make('redeemed_count')
                    ->label('Redeemed')
                    ->getStateUsing(fn (Coupon $coupon) => $coupon->redeemed_count . ' / ' . ($coupon->max_redemptions ?? '∞')),
                Infolists\Components\TextEntry::make('expires_at')->date()->placeholder('No expiry'),
                Infolists\Components\TextEntry::make('creator.email')->label('Created by')->default('-'),
                Infolists\Components\TextEntry::make('note')->columnSpanFull()->placeholder('-'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('code')->copyable()->searchable()->sortable(),
                Tables\Columns\TextColumn::make('type')->badge(),
                Tables\Columns\TextColumn::make('value')
                    ->label('Value')
                    ->getStateUsing(fn (Coupon $coupon) => static::valueLabel($coupon)),
                Tables\Columns\TextColumn::make('redeemed_count')
                    ->label('Redeemed')
                    ->getStateUsing(fn (Coupon $coupon) => $coupon->redeemed_count . ' / ' . ($coupon->max_redemptions ?? '∞')),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state) => $state === 'active' ? 'success' : 'gray'),
                Tables\Columns\TextColumn::make('expires_at')->date()->placeholder('No expiry')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')->options(['active' => 'Active', 'disabled' => 'Disabled']),
                Tables\Filters\SelectFilter::make('type')->options(['percent' => 'Percent', 'fixed' => 'Fixed']),
            ])
            ->actions([Actions\ViewAction::make(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([
                Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\RedemptionsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCoupons::route('/'),
            'create' => Pages\CreateCoupon::route('/create'),
            'view' => Pages\ViewCoupon::route('/{record}'),
            'edit' => Pages\EditCoupon::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'active')->count() ?: null;
    }

    public static function valueLabel(Coupon $coupon): string
    {
        return $coupon->type === 'percent'
            ? "{$coupon->value}%"
            : '$' . number_format($coupon->value / 100, 2);
    }
}
