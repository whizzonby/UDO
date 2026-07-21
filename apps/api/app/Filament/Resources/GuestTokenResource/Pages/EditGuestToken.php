<?php

namespace App\Filament\Resources\GuestTokenResource\Pages;

use App\Filament\Resources\GuestTokenResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditGuestToken extends EditRecord
{
    protected static string $resource = GuestTokenResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\ViewAction::make()];
    }
}
