<?php

namespace App\Filament\Resources\IdempotencyKeyResource\Pages;

use App\Filament\Resources\IdempotencyKeyResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewIdempotencyKey extends ViewRecord
{
    protected static string $resource = IdempotencyKeyResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
