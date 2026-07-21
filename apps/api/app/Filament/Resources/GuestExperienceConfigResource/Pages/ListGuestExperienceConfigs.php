<?php

namespace App\Filament\Resources\GuestExperienceConfigResource\Pages;

use App\Filament\Resources\GuestExperienceConfigResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListGuestExperienceConfigs extends ListRecords
{
    protected static string $resource = GuestExperienceConfigResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
