<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\GuestTokenResource;
use App\Models\GuestToken;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class TokenExpiryRiskWidget extends BaseWidget
{
    protected static ?string $heading = 'Token expiry risk';
    protected static ?int $sort = 2;
    protected static bool $isLazy = false;
    protected int|string|array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                GuestToken::query()
                    ->with(['wedding', 'guest'])
                    ->where('revoked', false)
                    ->whereNotNull('expires_at')
                    ->where('expires_at', '<', now()->addDays(7))
                    ->orderBy('expires_at')
                    ->limit(15)
            )
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->url(fn (GuestToken $token) => GuestTokenResource::getUrl('view', ['record' => $token])),
                Tables\Columns\TextColumn::make('guest.email')->label('Guest')->default('-'),
                Tables\Columns\TextColumn::make('view_type')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->getStateUsing(fn (GuestToken $token) => $token->expires_at->isPast() ? 'expired' : 'expiring soon')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'expired' ? 'danger' : 'warning'),
                Tables\Columns\TextColumn::make('expires_at')->since()->sortable(),
            ])
            ->emptyStateHeading('No token expiry risk')
            ->emptyStateDescription('No active guest token is expired or expiring within 7 days.');
    }
}
