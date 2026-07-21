<?php

namespace App\Filament\Resources\GuestExperienceConfigResource\Pages;

use App\Filament\Resources\GuestExperienceConfigResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditGuestExperienceConfig extends EditRecord
{
    protected static string $resource = GuestExperienceConfigResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\ViewAction::make()];
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        if (($data['publish_state'] ?? null) === 'published' && empty($data['published_at'])) {
            $data['published_at'] = now();
        }

        return $data;
    }
}
