<?php

namespace App\Services;

use App\Models\BudgetItem;
use App\Models\BudgetPaymentSchedule;
use App\Models\User;
use Illuminate\Support\Arr;

class AdminBudgetPaymentOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function markPaid(BudgetPaymentSchedule $schedule, User $actor, ?string $note = null): BudgetPaymentSchedule
    {
        $schedule->loadMissing(['budgetItem', 'wedding']);
        $beforeSchedule = $this->scheduleSnapshot($schedule);
        $beforeItem = $this->budgetItemSnapshot($schedule->budgetItem);

        $schedule->forceFill([
            'status' => 'paid',
            'paid_at' => now(),
            'notes' => $note
                ? trim(trim((string) $schedule->notes) . "\nAdmin payment note: {$note}")
                : $schedule->notes,
        ])->save();

        $this->refreshBudgetItemBalance($schedule->budgetItem);

        $freshSchedule = $schedule->fresh(['budgetItem', 'wedding']);
        $this->auditLogService->record(
            'admin.budget_payment_marked_paid',
            wedding: $freshSchedule->wedding,
            user: $actor,
            auditable: $freshSchedule,
            before: [
                'schedule' => $beforeSchedule,
                'budget_item' => $beforeItem,
            ],
            after: [
                'schedule' => $this->scheduleSnapshot($freshSchedule),
                'budget_item' => $this->budgetItemSnapshot($freshSchedule->budgetItem),
            ],
            metadata: [
                'budget_item_id' => $freshSchedule->budget_item_id,
                'vendor_id' => $freshSchedule->vendor_id,
                'note' => $note,
            ],
            request: request(),
        );

        return $freshSchedule;
    }

    public function refreshBudgetItemBalance(BudgetItem $budgetItem): BudgetItem
    {
        $paidAmount = $budgetItem->paymentSchedules()->where('status', 'paid')->sum('amount');
        $actualAmount = max((float) $budgetItem->actual_amount, (float) $budgetItem->estimated_amount);

        $budgetItem->forceFill([
            'paid_amount' => $paidAmount,
            'payment_status' => $paidAmount >= $actualAmount ? 'paid' : ($paidAmount > 0 ? 'partial' : 'pending'),
        ])->save();

        return $budgetItem->fresh();
    }

    public function normalizedStatus(BudgetPaymentSchedule $schedule): string
    {
        if ($schedule->status === 'paid') {
            return 'paid';
        }

        if ($schedule->due_date && now()->startOfDay()->gt($schedule->due_date->copy()->startOfDay())) {
            return 'overdue';
        }

        return $schedule->status ?: 'pending';
    }

    private function scheduleSnapshot(BudgetPaymentSchedule $schedule): array
    {
        return Arr::only($schedule->toArray(), [
            'id',
            'wedding_id',
            'budget_item_id',
            'vendor_id',
            'label',
            'amount',
            'due_date',
            'status',
            'paid_at',
            'reminder_at',
            'notes',
        ]);
    }

    private function budgetItemSnapshot(BudgetItem $budgetItem): array
    {
        return Arr::only($budgetItem->toArray(), [
            'id',
            'wedding_id',
            'vendor_id',
            'name',
            'estimated_amount',
            'actual_amount',
            'paid_amount',
            'payment_status',
        ]);
    }
}
