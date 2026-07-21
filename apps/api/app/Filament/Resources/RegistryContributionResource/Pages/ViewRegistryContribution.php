<?php

namespace App\Filament\Resources\RegistryContributionResource\Pages;

use App\Filament\Resources\RegistryContributionResource;
use Filament\Resources\Pages\ViewRecord;

class ViewRegistryContribution extends ViewRecord
{
    protected static string $resource = RegistryContributionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            RegistryContributionResource::markPaidAction(),
        ];
    }
}
