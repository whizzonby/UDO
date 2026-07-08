<?php

namespace App\Filament\Resources\TransportGroupResource\Pages;

use App\Filament\Resources\TransportGroupResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTransportGroups extends ListRecords
{
    protected static string $resource = TransportGroupResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
