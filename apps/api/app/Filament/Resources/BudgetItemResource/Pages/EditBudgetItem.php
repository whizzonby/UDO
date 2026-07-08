<?php

namespace App\Filament\Resources\BudgetItemResource\Pages;

use App\Filament\Resources\BudgetItemResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditBudgetItem extends EditRecord
{
    protected static string $resource = BudgetItemResource::class;

    protected function getHeaderActions(): array
    {
        return [Actions\DeleteAction::make()];
    }
}
