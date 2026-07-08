<?php

namespace App\Filament\Resources\TimelineItemResource\Pages;

use App\Filament\Resources\TimelineItemResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTimelineItems extends ListRecords
{
    protected static string $resource = TimelineItemResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
