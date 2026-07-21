<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\MessageResource;
use App\Models\Message;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class StaleMessagesWidget extends BaseWidget
{
    protected static ?string $heading = 'Stale sending messages';
    protected static ?int $sort = 1;
    protected static bool $isLazy = false;
    protected int|string|array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Message::query()
                    ->with('wedding')
                    ->where('status', 'sending')
                    ->where('updated_at', '<', now()->subMinutes(15))
                    ->orderBy('updated_at')
                    ->limit(15)
            )
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->url(fn (Message $message) => $message->wedding ? MessageResource::getUrl('edit', ['record' => $message]) : null),
                Tables\Columns\TextColumn::make('subject')->limit(40)->default('(no subject)'),
                Tables\Columns\TextColumn::make('channel')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('recipient_count')->label('Recipients'),
                Tables\Columns\TextColumn::make('updated_at')->label('Stuck since')->since()->sortable(),
            ])
            ->emptyStateHeading('No stale sends')
            ->emptyStateDescription('No message has been stuck in "sending" for more than 15 minutes.');
    }
}
