<?php

namespace App\Filament\Resources\CashFundContributionResource\Pages;

use App\Filament\Resources\CashFundContributionResource;
use Filament\Resources\Pages\ListRecords;

class ListContributions extends ListRecords
{
    protected static string $resource = CashFundContributionResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
