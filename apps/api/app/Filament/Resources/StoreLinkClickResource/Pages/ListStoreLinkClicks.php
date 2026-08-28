<?php

namespace App\Filament\Resources\StoreLinkClickResource\Pages;

use App\Filament\Resources\StoreLinkClickResource;
use App\Filament\Widgets\StoreClicksStatsWidget;
use Filament\Resources\Pages\ListRecords;

class ListStoreLinkClicks extends ListRecords
{
    protected static string $resource = StoreLinkClickResource::class;

    protected function getHeaderWidgets(): array
    {
        return [
            StoreClicksStatsWidget::class,
        ];
    }
}
