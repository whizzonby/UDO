<?php

namespace App\Filament\Resources\GuestTokenResource\Pages;

use App\Filament\Resources\GuestTokenResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListGuestTokens extends ListRecords
{
    protected static string $resource = GuestTokenResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
