<?php

namespace App\Filament\Resources\SeatingTableResource\Pages;

use App\Filament\Resources\SeatingTableResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSeatingTables extends ListRecords
{
    protected static string $resource = SeatingTableResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
