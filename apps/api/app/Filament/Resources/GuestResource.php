<?php

namespace App\Filament\Resources;

use App\Filament\Resources\GuestResource\Pages;
use App\Models\Guest;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class GuestResource extends Resource
{
    protected static ?string $model = Guest::class;
    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationLabel = 'Guests';
    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form->schema([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('first_name')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('last_name')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->placeholder('—'),

                Tables\Columns\TextColumn::make('wedding.partner_one_name')
                    ->label('Wedding')
                    ->searchable(),

                Tables\Columns\TextColumn::make('rsvp_status')
                    ->label('RSVP')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'attending' => 'success',
                        'declined'  => 'danger',
                        'maybe'     => 'warning',
                        default     => 'gray',
                    }),

                Tables\Columns\TextColumn::make('checked_in_at')
                    ->label('Checked in')
                    ->since()
                    ->placeholder('Not yet')
                    ->sortable(),

                Tables\Columns\IconColumn::make('invitation_sent_at')
                    ->label('Invited')
                    ->boolean()
                    ->trueIcon('heroicon-o-envelope')
                    ->falseIcon('heroicon-o-minus-circle')
                    ->getStateUsing(fn (Guest $record) => $record->invitation_sent_at !== null),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('rsvp_status')
                    ->label('RSVP status')
                    ->options([
                        'pending'   => 'Pending',
                        'attending' => 'Attending',
                        'declined'  => 'Declined',
                        'maybe'     => 'Maybe',
                    ]),

                Tables\Filters\Filter::make('checked_in')
                    ->label('Checked in only')
                    ->query(fn ($query) => $query->whereNotNull('checked_in_at')),

                Tables\Filters\Filter::make('invited')
                    ->label('Invited only')
                    ->query(fn ($query) => $query->whereNotNull('invitation_sent_at')),
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
            'index' => Pages\ListGuests::route('/'),
        ];
    }
}
