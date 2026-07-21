<?php

namespace App\Filament\Widgets;

use App\Filament\Resources\WeddingResource;
use App\Models\Guest;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class VipReadinessWidget extends BaseWidget
{
    protected static ?string $heading = 'VIP readiness gaps';
    protected static ?int $sort = 3;
    protected static bool $isLazy = false;
    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Guest::query()
                    ->with('wedding')
                    ->where('vip_flag', true)
                    ->where('attending_status', '!=', 'no')
                    ->whereHas('wedding', fn ($query) => $query->whereIn('status', ['final_week', 'live']))
                    ->where(function ($query) {
                        $query->whereNull('seating_assignment_id')
                            ->orWhere(function ($query) {
                                $query->where('travel_required', true)
                                    ->where(function ($query) {
                                        $query->whereNull('arrival_date')
                                            ->orWhereNull('hotel_assignment_id')
                                            ->orWhereNull('transport_assignment_id');
                                    });
                            });
                    })
                    ->limit(20)
            )
            ->columns([
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')
                    ->label('Wedding')
                    ->url(fn (Guest $guest) => $guest->wedding ? WeddingResource::getUrl('view', ['record' => $guest->wedding]) : null),
                Tables\Columns\TextColumn::make('full_name')
                    ->label('VIP guest')
                    ->getStateUsing(fn (Guest $guest) => $guest->full_name),
                Tables\Columns\TextColumn::make('gaps')
                    ->label('Gaps')
                    ->badge()
                    ->color('warning')
                    ->getStateUsing(fn (Guest $guest) => array_values(array_filter([
                        ! $guest->seating_assignment_id ? 'Seating' : null,
                        $guest->travel_required && ! $guest->arrival_date ? 'Arrival info' : null,
                        $guest->travel_required && ! $guest->hotel_assignment_id ? 'Accommodation' : null,
                        $guest->travel_required && ! $guest->transport_assignment_id ? 'Transport' : null,
                    ]))),
                Tables\Columns\IconColumn::make('travel_required')->boolean()->label('Travelling'),
            ])
            ->emptyStateHeading('No VIP gaps')
            ->emptyStateDescription('Every VIP guest at a live or final-week wedding has seating and travel logistics covered.');
    }
}
