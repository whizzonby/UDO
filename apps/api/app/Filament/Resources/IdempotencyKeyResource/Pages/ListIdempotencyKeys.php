<?php

namespace App\Filament\Resources\IdempotencyKeyResource\Pages;

use App\Filament\Resources\IdempotencyKeyResource;
use Filament\Resources\Pages\ListRecords;

class ListIdempotencyKeys extends ListRecords
{
    protected static string $resource = IdempotencyKeyResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
