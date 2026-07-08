<?php

namespace App\Filament\Resources\AccommodationOptionResource\Pages;

use App\Filament\Resources\AccommodationOptionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditAccommodationOption extends EditRecord
{
    protected static string $resource = AccommodationOptionResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
