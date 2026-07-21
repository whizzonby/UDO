<?php

namespace App\Filament\Resources\GalleryAssetResource\Pages;

use App\Filament\Resources\GalleryAssetResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewGalleryAsset extends ViewRecord
{
    protected static string $resource = GalleryAssetResource::class;

    protected function getHeaderActions(): array
    {
        return [
            GalleryAssetResource::moderationAction('approve', 'Approve', 'heroicon-o-check-circle', 'success'),
            GalleryAssetResource::moderationAction('reject', 'Reject', 'heroicon-o-x-circle', 'danger'),
            GalleryAssetResource::moderationAction('feature', 'Feature', 'heroicon-o-star', 'warning'),
            GalleryAssetResource::moderationAction('archive', 'Archive', 'heroicon-o-archive-box', 'gray'),
            Actions\EditAction::make(),
        ];
    }
}
