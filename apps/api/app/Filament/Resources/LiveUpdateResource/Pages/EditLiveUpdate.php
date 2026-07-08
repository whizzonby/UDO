<?php

namespace App\Filament\Resources\LiveUpdateResource\Pages;

use App\Filament\Resources\LiveUpdateResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditLiveUpdate extends EditRecord
{
    protected static string $resource = LiveUpdateResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
