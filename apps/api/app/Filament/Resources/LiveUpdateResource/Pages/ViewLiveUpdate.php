<?php

namespace App\Filament\Resources\LiveUpdateResource\Pages;

use App\Filament\Resources\LiveUpdateResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewLiveUpdate extends ViewRecord
{
    protected static string $resource = LiveUpdateResource::class;

    protected function getHeaderActions(): array
    {
        return [
            LiveUpdateResource::resolveAction(),
            Actions\EditAction::make(),
        ];
    }
}
