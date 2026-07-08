<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RegistryContributionResource\Pages;
use App\Models\RegistryContribution;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class RegistryContributionResource extends Resource
{
    protected static ?string $model = RegistryContribution::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-banknotes';
    protected static string|\UnitEnum|null $navigationGroup = 'Business';
    protected static ?int $navigationSort = 2;
    protected static ?string $navigationLabel = 'Registry contributions';

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('item.name')->label('Item')->searchable(),
                Tables\Columns\TextColumn::make('item.wedding.couple_name_primary')
                    ->label('Wedding')
                    ->searchable(),
                Tables\Columns\TextColumn::make('contributor_name')->label('From')->searchable(),
                Tables\Columns\TextColumn::make('amount')->money('usd')->sortable(),
                Tables\Columns\TextColumn::make('payment_status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'succeeded' => 'success',
                        'failed'    => 'danger',
                        'refunded'  => 'warning',
                        default     => 'gray',
                    }),
                Tables\Columns\TextColumn::make('message')->limit(40)->toggleable(),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('payment_status')
                    ->options(['pending' => 'Pending', 'succeeded' => 'Succeeded', 'failed' => 'Failed', 'refunded' => 'Refunded']),
            ])
            ->actions([Actions\ViewAction::make()])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRegistryContributions::route('/'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }
}
