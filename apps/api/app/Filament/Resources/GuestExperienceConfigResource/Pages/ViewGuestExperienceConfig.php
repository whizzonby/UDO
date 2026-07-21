<?php

namespace App\Filament\Resources\GuestExperienceConfigResource\Pages;

use App\Filament\Resources\GuestExperienceConfigResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewGuestExperienceConfig extends ViewRecord
{
    protected static string $resource = GuestExperienceConfigResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\EditAction::make()];
    }
}
