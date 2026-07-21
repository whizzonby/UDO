<?php

namespace App\Filament\Resources\GuestExperienceConfigResource\Pages;

use App\Filament\Resources\GuestExperienceConfigResource;
use Filament\Resources\Pages\CreateRecord;

class CreateGuestExperienceConfig extends CreateRecord
{
    protected static string $resource = GuestExperienceConfigResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (($data['publish_state'] ?? null) === 'published') {
            $data['published_at'] = $data['published_at'] ?? now();
        }

        return $data;
    }
}
