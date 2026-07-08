<?php

namespace App\Filament\Resources\LiveUpdateResource\Pages;

use App\Filament\Resources\LiveUpdateResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListLiveUpdates extends ListRecords
{
    protected static string $resource = LiveUpdateResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
