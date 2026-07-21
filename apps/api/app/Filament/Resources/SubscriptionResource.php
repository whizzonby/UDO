<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\SubscriptionResource\Pages;
use App\Filament\Resources\SubscriptionResource\RelationManagers;
use App\Models\Subscription;
use App\Models\Wedding;
use App\Services\SubscriptionEntitlementService;
use BackedEnum;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class SubscriptionResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.finance';

    protected static ?string $model = Subscription::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-star';
    protected static string|UnitEnum|null $navigationGroup = 'Finance & Support';
    protected static ?int $navigationSort = 1;

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\Select::make('user_id')
                ->relationship('user', 'email')
                ->searchable()
                ->required()
                ->label('User'),
            Forms\Components\Select::make('plan')
                ->options(static::planOptions())
                ->required(),
            Forms\Components\Select::make('status')
                ->options(static::statusOptions())
                ->required(),
            Forms\Components\Select::make('billing_cycle')
                ->options(static::billingCycleOptions()),
            Forms\Components\TextInput::make('amount')->numeric()->prefix('$'),
            Forms\Components\TextInput::make('currency')->maxLength(3)->default('USD'),
            Forms\Components\TextInput::make('stripe_customer_id')->label('Stripe customer ID')->maxLength(255),
            Forms\Components\TextInput::make('stripe_subscription_id')->label('Stripe subscription ID')->maxLength(255),
            Forms\Components\TextInput::make('stripe_price_id')->label('Stripe price ID')->maxLength(255),
            Forms\Components\DateTimePicker::make('trial_ends_at')->native(false)->label('Trial ends'),
            Forms\Components\DateTimePicker::make('current_period_start')->native(false)->label('Period starts'),
            Forms\Components\DateTimePicker::make('current_period_end')->native(false)->label('Period ends'),
            Forms\Components\DateTimePicker::make('cancelled_at')->native(false)->label('Cancelled at'),
            Forms\Components\DateTimePicker::make('ends_at')->native(false)->label('Access ends'),
        ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Subscription')->columns(3)->schema([
                Infolists\Components\TextEntry::make('user.email')->label('User')->copyable(),
                Infolists\Components\TextEntry::make('plan')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'starter' => 'info',
                        'pro' => 'success',
                        'elite' => 'warning',
                        default => 'gray',
                    }),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'trialing' => 'info',
                        'past_due' => 'warning',
                        default => 'danger',
                    }),
                Infolists\Components\TextEntry::make('billing_cycle'),
                Infolists\Components\TextEntry::make('amount')->money('usd'),
                Infolists\Components\TextEntry::make('currency'),
                Infolists\Components\TextEntry::make('stripe_customer_id')->label('Stripe customer')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('stripe_subscription_id')->label('Stripe subscription')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('stripe_price_id')->label('Active Stripe price')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('current_period_start')->label('Period start')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('current_period_end')->label('Period end')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('trial_ends_at')->label('Trial ends')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('cancelled_at')->label('Cancelled')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('ends_at')->label('Access ends')->date()->placeholder('-'),
            ]),
            \Filament\Schemas\Components\Section::make('Entitlements and usage')->columns(3)->schema([
                Infolists\Components\TextEntry::make('usage.guests')
                    ->label('Guests')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageLine($subscription, 'guests')),
                Infolists\Components\TextEntry::make('usage.team_members')
                    ->label('Team members')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageLine($subscription, 'team_members')),
                Infolists\Components\TextEntry::make('usage.messages_per_month')
                    ->label('Messages this month')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageLine($subscription, 'messages_per_month')),
                Infolists\Components\TextEntry::make('usage.gallery_assets')
                    ->label('Gallery assets')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageLine($subscription, 'gallery_assets')),
                Infolists\Components\TextEntry::make('usage.weddings')
                    ->label('Weddings')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageLine($subscription, 'weddings')),
                Infolists\Components\TextEntry::make('usage.source_wedding')
                    ->label('Usage source')
                    ->getStateUsing(fn (Subscription $subscription) => static::usageSource($subscription)),
            ]),
            \Filament\Schemas\Components\Section::make('Configured Stripe prices and overrides')->columns(2)->schema([
                Infolists\Components\TextEntry::make('configured_price_monthly')
                    ->label('Configured monthly price ID')
                    ->copyable()
                    ->getStateUsing(fn (Subscription $subscription) => config("services.billing.stripe_prices.{$subscription->plan}.monthly") ?: '-'),
                Infolists\Components\TextEntry::make('configured_price_annual')
                    ->label('Configured annual price ID')
                    ->copyable()
                    ->getStateUsing(fn (Subscription $subscription) => config("services.billing.stripe_prices.{$subscription->plan}.annual") ?: '-'),
                Infolists\Components\TextEntry::make('metadata.last_admin_override')
                    ->label('Last admin override')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
                Infolists\Components\TextEntry::make('metadata.last_ops_override')
                    ->label('Last internal ops override')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.email')->label('User')->copyable()->searchable()->sortable(),
                Tables\Columns\TextColumn::make('plan')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'starter' => 'info',
                        'pro' => 'success',
                        'elite' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active' => 'success',
                        'trialing' => 'info',
                        'past_due' => 'warning',
                        default => 'danger',
                    }),
                Tables\Columns\TextColumn::make('billing_cycle')->toggleable(),
                Tables\Columns\TextColumn::make('amount')->money('usd')->sortable(),
                Tables\Columns\TextColumn::make('stripe_price_id')->label('Stripe price')->copyable()->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('current_period_end')->date()->label('Renews')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('plan')
                    ->options(static::planOptions()),
                Tables\Filters\SelectFilter::make('status')
                    ->options(static::statusOptions()),
            ])
            ->actions([Actions\ViewAction::make(), Actions\EditAction::make()])
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
            'index' => Pages\ListSubscriptions::route('/'),
            'create' => Pages\CreateSubscription::route('/create'),
            'view' => Pages\ViewSubscription::route('/{record}'),
            'edit' => Pages\EditSubscription::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', 'active')->where('plan', '!=', 'free')->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }

    public static function planOptions(): array
    {
        return collect(SubscriptionEntitlementService::PLANS)
            ->mapWithKeys(fn (array $definition, string $key) => [$key => $definition['label']])
            ->all();
    }

    public static function statusOptions(): array
    {
        return [
            'active' => 'Active',
            'trialing' => 'Trialing',
            'past_due' => 'Past due',
            'cancelled' => 'Cancelled',
            'expired' => 'Expired',
        ];
    }

    public static function billingCycleOptions(): array
    {
        return [
            'monthly' => 'Monthly',
            'annual' => 'Annual',
        ];
    }

    public static function usageLine(Subscription $subscription, string $key): string
    {
        $payload = static::entitlementPayload($subscription);
        if (! $payload) {
            return 'No wedding workspace';
        }

        $usage = $payload['usage'][$key] ?? 0;
        $limit = $payload['limits'][$key] ?? null;

        return $usage . ' / ' . ($limit === null ? 'Unlimited' : $limit);
    }

    public static function usageSource(Subscription $subscription): string
    {
        $wedding = static::usageWedding($subscription);

        if (! $wedding) {
            return 'No wedding workspace';
        }

        return ($wedding->title ?: trim($wedding->couple_name_primary . ' & ' . $wedding->couple_name_secondary, ' &')) . " (#{$wedding->id})";
    }

    private static function entitlementPayload(Subscription $subscription): ?array
    {
        $wedding = static::usageWedding($subscription);

        return $wedding
            ? app(SubscriptionEntitlementService::class)->payloadFor($wedding)
            : null;
    }

    private static function usageWedding(Subscription $subscription): ?Wedding
    {
        $user = $subscription->user;

        return $user?->activeWedding ?: $user?->ownedWeddings()->latest()->first();
    }
}
