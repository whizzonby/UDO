<?php

namespace App\Filament\Resources\BudgetItemResource\Pages;

use App\Filament\Resources\BudgetItemResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewBudgetItem extends ViewRecord
{
    protected static string $resource = BudgetItemResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
