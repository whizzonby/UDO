<?php

namespace App\Filament\Resources\ThankYouRecordResource\Pages;

use App\Filament\Resources\ThankYouRecordResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewThankYouRecord extends ViewRecord
{
    protected static string $resource = ThankYouRecordResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ThankYouRecordResource::markSentAction(),
            Actions\EditAction::make(),
        ];
    }
}
