<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WeddingResource\Pages;
use App\Models\Wedding;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class WeddingResource extends Resource
{
    protected static ?string $model = Wedding::class;
    protected static ?string $navigationIcon = 'heroicon-o-heart';
    protected static ?string $navigationLabel = 'Weddings';
    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('partner_one_name')
                    ->label('Partner 1')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('partner_two_name')
                    ->label('Partner 2')
                    ->searchable()
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'live'      => 'success',
                        'planning'  => 'info',
                        'completed' => 'gray',
                        default     => 'gray',
                    }),

                Tables\Columns\TextColumn::make('wedding_date')
                    ->date('M j, Y')
                    ->sortable()
                    ->placeholder('TBD'),

                Tables\Columns\TextColumn::make('venue_name')
                    ->label('Venue')
                    ->placeholder('—')
                    ->limit(30),

                Tables\Columns\TextColumn::make('guests_count')
                    ->label('Guests')
                    ->counts('guests')
                    ->sortable(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Created')
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'planning'  => 'Planning',
                        'live'      => 'Live',
                        'completed' => 'Completed',
                    ]),
            ])
            ->actions([
                Tables\Actions\Action::make('activate')
                    ->label('Go Live')
                    ->icon('heroicon-m-signal')
                    ->color('success')
                    ->visible(fn (Wedding $record) => $record->status !== 'live')
                    ->action(fn (Wedding $record) => $record->update(['status' => 'live']))
                    ->requiresConfirmation(),

                Tables\Actions\Action::make('deactivate')
                    ->label('End Live')
                    ->icon('heroicon-m-stop-circle')
                    ->color('danger')
                    ->visible(fn (Wedding $record) => $record->status === 'live')
                    ->action(fn (Wedding $record) => $record->update(['status' => 'planning']))
                    ->requiresConfirmation(),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListWeddings::route('/'),
        ];
    }
}
