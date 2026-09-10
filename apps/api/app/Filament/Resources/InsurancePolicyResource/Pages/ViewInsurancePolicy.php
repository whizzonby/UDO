<?php

namespace App\Filament\Resources\InsurancePolicyResource\Pages;

use App\Filament\Resources\InsurancePolicyResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewInsurancePolicy extends ViewRecord
{
    protected static string $resource = InsurancePolicyResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
