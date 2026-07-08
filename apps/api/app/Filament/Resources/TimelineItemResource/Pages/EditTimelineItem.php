<?php

namespace App\Filament\Resources\TimelineItemResource\Pages;

use App\Filament\Resources\TimelineItemResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditTimelineItem extends EditRecord
{
    protected static string $resource = TimelineItemResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
