<?php

namespace App\Filament\Resources\SeatingTableResource\Pages;

use App\Filament\Resources\SeatingTableResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSeatingTable extends EditRecord
{
    protected static string $resource = SeatingTableResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
