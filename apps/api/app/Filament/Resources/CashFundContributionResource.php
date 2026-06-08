<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CashFundContributionResource\Pages;
use App\Models\CashFundContribution;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class CashFundContributionResource extends Resource
{
    protected static ?string $model = CashFundContribution::class;
    protected static ?string $navigationIcon = 'heroicon-o-banknotes';
    protected static ?string $navigationLabel = 'Contributions';
    protected static ?int $navigationSort = 4;

    public static function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('contributor_name')
                    ->label('Contributor')
                    ->searchable()
                    ->placeholder('Anonymous'),

                Tables\Columns\TextColumn::make('amount')
                    ->money(fn (CashFundContribution $record) => strtoupper($record->currency))
                    ->sortable(),

                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'paid'    => 'success',
                        'pending' => 'warning',
                        'failed'  => 'danger',
                        default   => 'gray',
                    }),

                Tables\Columns\TextColumn::make('cashFund.title')
                    ->label('Fund')
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('cashFund.wedding.partner_one_name')
                    ->label('Wedding')
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('contributor_email')
                    ->label('Email')
                    ->placeholder('—')
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('stripe_session_id')
                    ->label('Session ID')
                    ->limit(24)
                    ->toggleable(isToggledHiddenByDefault: true),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Time')
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'paid'    => 'Paid',
                        'failed'  => 'Failed',
                    ]),
            ])
            ->actions([])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListContributions::route('/'),
        ];
    }
}
