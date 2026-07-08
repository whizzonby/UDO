<?php

namespace App\Filament\Resources\WeddingCollaboratorResource\Pages;

use App\Filament\Resources\WeddingCollaboratorResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListWeddingCollaborators extends ListRecords
{
    protected static string $resource = WeddingCollaboratorResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\CreateAction::make()];
    }
}
