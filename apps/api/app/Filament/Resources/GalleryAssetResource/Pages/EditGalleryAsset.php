<?php

namespace App\Filament\Resources\GalleryAssetResource\Pages;

use App\Filament\Resources\GalleryAssetResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditGalleryAsset extends EditRecord
{
    protected static string $resource = GalleryAssetResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
