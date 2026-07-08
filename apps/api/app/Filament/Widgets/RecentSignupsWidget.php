<?php

namespace App\Filament\Widgets;

use App\Models\User;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class RecentSignupsWidget extends BaseWidget
{
    protected static ?string $heading = 'Recent sign-ups';
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(User::latest()->limit(10))
            ->columns([
                Tables\Columns\TextColumn::make('full_name')
                    ->label('Name')
                    ->searchable(['first_name', 'last_name', 'name'])
                    ->getStateUsing(fn (User $u) => trim(($u->first_name ?? $u->name) . ' ' . $u->last_name)),
                Tables\Columns\TextColumn::make('email')->copyable(),
                Tables\Columns\TextColumn::make('ownedWeddings.couple_name_primary')
                    ->label('Wedding')
                    ->default('—'),
                Tables\Columns\TextColumn::make('onboarding_completed')
                    ->label('Onboarded')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                    ->color(fn ($state) => $state ? 'success' : 'warning'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Signed up')
                    ->since()
                    ->sortable(),
            ]);
    }
}
