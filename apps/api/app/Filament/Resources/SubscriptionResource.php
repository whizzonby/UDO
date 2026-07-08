<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SubscriptionResource\Pages;
use App\Models\Subscription;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class SubscriptionResource extends Resource
{
    protected static ?string $model = Subscription::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-star';
    protected static string|\UnitEnum|null $navigationGroup = 'Business';
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
                ->options(['free' => 'Free', 'starter' => 'Starter', 'pro' => 'Pro', 'elite' => 'Elite'])
                ->required(),
            Forms\Components\Select::make('status')
                ->options(['active' => 'Active', 'trialing' => 'Trialing', 'past_due' => 'Past due', 'cancelled' => 'Cancelled', 'expired' => 'Expired'])
                ->required(),
            Forms\Components\Select::make('billing_cycle')
                ->options(['monthly' => 'Monthly', 'annual' => 'Annual']),
            Forms\Components\TextInput::make('amount')->numeric()->prefix('$'),
            Forms\Components\DateTimePicker::make('trial_ends_at')->native(false)->label('Trial ends'),
            Forms\Components\DateTimePicker::make('current_period_end')->native(false)->label('Period ends'),
            Forms\Components\DateTimePicker::make('cancelled_at')->native(false)->label('Cancelled at'),
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
                        'pro'     => 'success',
                        'elite'   => 'warning',
                        default   => 'gray',
                    }),
                Infolists\Components\TextEntry::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active'   => 'success',
                        'trialing' => 'info',
                        'past_due' => 'warning',
                        default    => 'danger',
                    }),
                Infolists\Components\TextEntry::make('billing_cycle'),
                Infolists\Components\TextEntry::make('amount')->money('usd'),
                Infolists\Components\TextEntry::make('stripe_customer_id')->label('Stripe customer')->copyable(),
                Infolists\Components\TextEntry::make('current_period_start')->label('Period start')->date(),
                Infolists\Components\TextEntry::make('current_period_end')->label('Period end')->date(),
                Infolists\Components\TextEntry::make('cancelled_at')->label('Cancelled')->date()->default('—'),
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
                        'pro'     => 'success',
                        'elite'   => 'warning',
                        default   => 'gray',
                    }),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'active'   => 'success',
                        'trialing' => 'info',
                        'past_due' => 'warning',
                        default    => 'danger',
                    }),
                Tables\Columns\TextColumn::make('billing_cycle')->toggleable(),
                Tables\Columns\TextColumn::make('amount')->money('usd')->sortable(),
                Tables\Columns\TextColumn::make('current_period_end')->date()->label('Renews')->sortable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('plan')
                    ->options(['free' => 'Free', 'starter' => 'Starter', 'pro' => 'Pro', 'elite' => 'Elite']),
                Tables\Filters\SelectFilter::make('status')
                    ->options(['active' => 'Active', 'trialing' => 'Trialing', 'past_due' => 'Past due', 'cancelled' => 'Cancelled']),
            ])
            ->actions([Actions\ViewAction::make(), Actions\EditAction::make()])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListSubscriptions::route('/'),
            'view'   => Pages\ViewSubscription::route('/{record}'),
            'edit'   => Pages\EditSubscription::route('/{record}/edit'),
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
}
