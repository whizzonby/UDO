<?php

namespace App\Filament\Resources\GalleryAssetResource\Pages;

use App\Filament\Resources\GalleryAssetResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListGalleryAssets extends ListRecords
{
    protected static string $resource = GalleryAssetResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
