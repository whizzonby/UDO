<?php

namespace App\Filament\Resources\BudgetPaymentScheduleResource\Pages;

use App\Filament\Resources\BudgetPaymentScheduleResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewBudgetPaymentSchedule extends ViewRecord
{
    protected static string $resource = BudgetPaymentScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            BudgetPaymentScheduleResource::markPaidAction(),
            Actions\EditAction::make(),
        ];
    }
}
