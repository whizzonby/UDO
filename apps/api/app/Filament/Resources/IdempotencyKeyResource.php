<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\IdempotencyKeyResource\Pages;
use App\Models\IdempotencyKey;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

class IdempotencyKeyResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = IdempotencyKey::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-finger-print';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 19;
    protected static ?string $recordTitleAttribute = 'key';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Idempotency key')->columns(3)->schema([
                Infolists\Components\TextEntry::make('key')->copyable()->columnSpanFull(),
                Infolists\Components\TextEntry::make('user.email')->label('User')->copyable()->default('-'),
                Infolists\Components\TextEntry::make('method')->badge()->color('gray'),
                Infolists\Components\TextEntry::make('path')->copyable(),
                Infolists\Components\TextEntry::make('status_code')->label('Replayed status')->badge()
                    ->color(fn (?int $state): string => match (true) {
                        $state === null => 'gray',
                        $state >= 500 => 'danger',
                        $state >= 400 => 'warning',
                        default => 'success',
                    }),
                Infolists\Components\TextEntry::make('request_hash')->label('Request hash')->copyable(),
                Infolists\Components\TextEntry::make('created_at')->label('First seen')->dateTime(),
                Infolists\Components\TextEntry::make('expires_at')->since()->placeholder('-'),
                Infolists\Components\TextEntry::make('validity')
                    ->label('Validity')
                    ->badge()
                    ->getStateUsing(fn (IdempotencyKey $key) => $key->expires_at && $key->expires_at->isFuture() ? 'active' : 'expired')
                    ->color(fn (string $state): string => $state === 'active' ? 'success' : 'gray'),
            ]),
            \Filament\Schemas\Components\Section::make('Replay metadata')->schema([
                Infolists\Components\TextEntry::make('response_body')
                    ->label('Stored response body')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('key')->copyable()->limit(24)->searchable(),
                Tables\Columns\TextColumn::make('user.email')->label('User')->searchable()->default('-'),
                Tables\Columns\TextColumn::make('method')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('path')->searchable()->limit(40),
                Tables\Columns\TextColumn::make('status_code')->label('Status')->badge()
                    ->color(fn (?int $state): string => match (true) {
                        $state === null => 'gray',
                        $state >= 500 => 'danger',
                        $state >= 400 => 'warning',
                        default => 'success',
                    }),
                Tables\Columns\TextColumn::make('created_at')->label('First seen')->since()->sortable(),
                Tables\Columns\TextColumn::make('expires_at')->since()->sortable()->placeholder('-'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('method')
                    ->options(['POST' => 'POST', 'PUT' => 'PUT', 'PATCH' => 'PATCH', 'DELETE' => 'DELETE']),
                Tables\Filters\Filter::make('active')
                    ->query(fn ($query) => $query->where('expires_at', '>', now()))
                    ->label('Active only'),
                Tables\Filters\Filter::make('expired')
                    ->query(fn ($query) => $query->where('expires_at', '<=', now()))
                    ->label('Expired only'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('No idempotency keys')
            ->emptyStateDescription('Keys appear here once a client retries a write with an Idempotency-Key header.');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListIdempotencyKeys::route('/'),
            'view' => Pages\ViewIdempotencyKey::route('/{record}'),
        ];
    }
}
