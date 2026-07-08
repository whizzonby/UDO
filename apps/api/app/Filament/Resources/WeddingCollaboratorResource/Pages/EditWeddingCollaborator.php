<?php

namespace App\Filament\Resources\WeddingCollaboratorResource\Pages;

use App\Filament\Resources\WeddingCollaboratorResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditWeddingCollaborator extends EditRecord
{
    protected static string $resource = WeddingCollaboratorResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
