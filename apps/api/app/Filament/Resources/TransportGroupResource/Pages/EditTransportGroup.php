<?php

namespace App\Filament\Resources\TransportGroupResource\Pages;

use App\Filament\Resources\TransportGroupResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditTransportGroup extends EditRecord
{
    protected static string $resource = TransportGroupResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
