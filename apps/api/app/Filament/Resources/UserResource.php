<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Filament\Resources\UserResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class UserResource extends Resource
{
    protected static ?string $model = User::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-user';
    protected static string|\UnitEnum|null $navigationGroup = 'Platform';
    protected static ?int $navigationSort = 1;
    protected static ?string $recordTitleAttribute = 'email';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Identity')->columns(2)->schema([
                Forms\Components\TextInput::make('first_name')->maxLength(100),
                Forms\Components\TextInput::make('last_name')->maxLength(100),
                Forms\Components\TextInput::make('name')->label('Display name')->required()->maxLength(255),
                Forms\Components\TextInput::make('email')->email()->required()->unique(ignoreRecord: true)->maxLength(255),
                Forms\Components\TextInput::make('phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('avatar_url')->label('Avatar URL')->url()->maxLength(500)->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Account')->columns(2)->schema([
                Forms\Components\TextInput::make('password')
                    ->password()
                    ->revealable()
                    ->dehydrateStateUsing(fn ($state) => filled($state) ? bcrypt($state) : null)
                    ->dehydrated(fn ($state) => filled($state))
                    ->label('New password (leave blank to keep current)'),
                Forms\Components\Toggle::make('onboarding_completed')->label('Onboarding completed'),
                Forms\Components\Select::make('roles')
                    ->relationship('roles', 'name')
                    ->multiple()
                    ->preload()
                    ->label('Roles'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->sortable()->searchable(),
                Tables\Columns\TextColumn::make('full_name')
                    ->label('Name')
                    ->getStateUsing(fn (User $u) => trim(($u->first_name ?? '') . ' ' . ($u->last_name ?? '')) ?: $u->name)
                    ->searchable(['first_name', 'last_name', 'name'])
                    ->sortable(),
                Tables\Columns\TextColumn::make('email')->copyable()->searchable()->sortable(),
                Tables\Columns\TextColumn::make('phone')->searchable()->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('ownedWeddings_count')
                    ->label('Weddings')
                    ->counts('ownedWeddings')
                    ->sortable(),
                Tables\Columns\TextColumn::make('onboarding_completed')
                    ->label('Onboarded')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                    ->color(fn ($state) => $state ? 'success' : 'warning'),
                Tables\Columns\TextColumn::make('auth_provider')
                    ->label('Auth')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'google' => 'info',
                        'apple' => 'gray',
                        default => 'success',
                    })
                    ->formatStateUsing(fn ($state) => $state ?? 'email'),
                Tables\Columns\TextColumn::make('subscription.plan')
                    ->label('Plan')
                    ->badge()
                    ->color(fn ($state) => match ($state) {
                        'pro' => 'success',
                        'elite' => 'warning',
                        'starter' => 'info',
                        default => 'gray',
                    })
                    ->default('free'),
                Tables\Columns\TextColumn::make('created_at')->label('Joined')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('onboarding_completed')->label('Onboarding'),
                Tables\Filters\SelectFilter::make('auth_provider')
                    ->options(['email' => 'Email', 'google' => 'Google', 'apple' => 'Apple']),
            ])
            ->actions([
                Actions\EditAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\WeddingsRelationManager::class,
            RelationManagers\SubscriptionsRelationManager::class,
            RelationManagers\SupportTicketsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit'   => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }
}
