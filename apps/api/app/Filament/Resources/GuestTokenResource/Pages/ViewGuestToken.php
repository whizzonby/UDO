<?php

namespace App\Filament\Resources\GuestTokenResource\Pages;

use App\Filament\Resources\GuestTokenResource;
use Filament\Resources\Pages\ViewRecord;

class ViewGuestToken extends ViewRecord
{
    protected static string $resource = GuestTokenResource::class;

    protected function getHeaderActions(): array
    {
        return [
            GuestTokenResource::extendAction(),
            GuestTokenResource::revokeAction(),
            GuestTokenResource::restoreAction(),
        ];
    }
}
