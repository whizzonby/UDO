<?php

namespace App\Filament\Resources\AccommodationOptionResource\Pages;

use App\Filament\Resources\AccommodationOptionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListAccommodationOptions extends ListRecords
{
    protected static string $resource = AccommodationOptionResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
