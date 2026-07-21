<?php

namespace App\Filament\Resources\FailedJobResource\Pages;

use App\Filament\Resources\FailedJobResource;
use Filament\Resources\Pages\ViewRecord;

class ViewFailedJob extends ViewRecord
{
    protected static string $resource = FailedJobResource::class;

    protected function getHeaderActions(): array
    {
        return [
            FailedJobResource::retryAction()->after(fn () => $this->redirect(FailedJobResource::getUrl('index'))),
            FailedJobResource::forgetAction()->after(fn () => $this->redirect(FailedJobResource::getUrl('index'))),
        ];
    }
}
