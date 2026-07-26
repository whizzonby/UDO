<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\BudgetItem;
use App\Models\BudgetPaymentSchedule;
use App\Services\ApprovalGatingService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_budget'), 403);
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $items = $wedding->budgetItems()->with(['vendor', 'paymentSchedules'])->orderBy('category')->get();

        $summary = $this->summaryPayload($wedding, $items);

        return response()->json([
            'data' => $items,
            'summary' => $summary,
        ]);
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $items = $wedding->budgetItems()->with(['vendor', 'paymentSchedules'])->orderBy('category')->get();

        return response()->json(['data' => $this->summaryPayload($wedding, $items)]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'total_budget'   => 'nullable|numeric|min:0',
            'name'           => 'required|string|max:255',
            'category'       => 'nullable|string|max:100',
            'vendor_id'      => 'nullable|integer|exists:vendors,id',
            'estimated_amount' => 'nullable|numeric|min:0',
            'actual_amount'    => 'nullable|numeric|min:0',
            'paid_amount'      => 'nullable|numeric|min:0',
            'payment_status'   => 'nullable|in:pending,partial,paid',
            'due_date'         => 'nullable|date',
            'notes'            => 'nullable|string',
            'is_essential'     => 'nullable|boolean',
            'payment_schedule' => 'nullable|array',
            'payment_schedule.*.label' => 'required_with:payment_schedule|string|max:255',
            'payment_schedule.*.amount' => 'required_with:payment_schedule|numeric|min:0',
            'payment_schedule.*.due_date' => 'nullable|date',
            'payment_schedule.*.status' => 'nullable|in:pending,scheduled,paid,overdue',
            'payment_schedule.*.reminder_at' => 'nullable|date',
            'payment_schedule.*.notes' => 'nullable|string',
        ]);

        if (isset($data['total_budget'])) {
            $settings = $wedding->settings ?? [];
            $settings['total_budget'] = $data['total_budget'];
            $wedding->update(['settings' => $settings]);
            unset($data['total_budget']);
        }

        $schedule = $data['payment_schedule'] ?? [];
        unset($data['payment_schedule']);
        $data['vendor_id'] = $this->authorizedVendorId($request, $data['vendor_id'] ?? null);

        $item = $wedding->budgetItems()->create($data);
        $this->syncCreatedSchedules($wedding, $item, $schedule);

        return response()->json(['data' => $item->load(['vendor', 'paymentSchedules'])], 201);
    }

    public function show(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        $this->authorize($request, $budgetItem);
        return response()->json(['data' => $budgetItem->load('vendor')]);
    }

    public function update(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        $this->authorize($request, $budgetItem);

        $data = $request->validate([
            'name'           => 'sometimes|string|max:255',
            'category'       => 'nullable|string|max:100',
            'vendor_id'      => 'nullable|integer|exists:vendors,id',
            'estimated_amount' => 'nullable|numeric|min:0',
            'actual_amount'    => 'nullable|numeric|min:0',
            'paid_amount'      => 'nullable|numeric|min:0',
            'payment_status'   => 'nullable|in:pending,partial,paid',
            'due_date'       => 'nullable|date',
            'notes'          => 'nullable|string',
            'is_essential'   => 'nullable|boolean',
        ]);

        if (array_key_exists('vendor_id', $data)) {
            $data['vendor_id'] = $this->authorizedVendorId($request, $data['vendor_id']);
        }

        $wedding = $budgetItem->wedding;
        $currentAmount = (float) ($budgetItem->estimated_amount ?? 0);
        $newAmount = array_key_exists('estimated_amount', $data) ? (float) $data['estimated_amount'] : null;
        $isIncrease = $newAmount !== null && $newAmount > $currentAmount;

        if ($isIncrease) {
            $threshold = ($wedding->settings ?? [])['approval_auto_threshold'] ?? null;
            $increaseBy = $newAmount - $currentAmount;

            if ($threshold === null || $increaseBy >= (float) $threshold) {
                $result = app(ApprovalGatingService::class)->requestOrApply(
                    $wedding,
                    'budget',
                    $budgetItem,
                    $data,
                    $request->user(),
                    "Budget increase: {$budgetItem->name}",
                    sprintf('Estimated amount increasing from $%s to $%s.', number_format($currentAmount, 2), number_format($newAmount, 2)),
                );

                if ($result['gated']) {
                    return response()->json([
                        'data' => $budgetItem->fresh()->load(['vendor', 'paymentSchedules']),
                        'gated' => true,
                        'approval_request_id' => $result['request']->id,
                    ]);
                }

                return response()->json(['data' => $result['subject']->load(['vendor', 'paymentSchedules']), 'gated' => false]);
            }
        }

        $budgetItem->update($data);

        return response()->json(['data' => $budgetItem->fresh()->load(['vendor', 'paymentSchedules']), 'gated' => false]);
    }

    public function destroy(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        $this->authorize($request, $budgetItem);
        $budgetItem->delete();
        return response()->json(null, 204);
    }

    public function storePaymentSchedule(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        $this->authorize($request, $budgetItem);

        $data = $request->validate([
            'label' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0',
            'due_date' => 'nullable|date',
            'status' => 'nullable|in:pending,scheduled,paid,overdue',
            'paid_at' => 'nullable|date',
            'reminder_at' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        $schedule = $budgetItem->paymentSchedules()->create([
            ...$data,
            'wedding_id' => $budgetItem->wedding_id,
            'vendor_id' => $budgetItem->vendor_id,
            'status' => $this->normalizedPaymentStatus($data['status'] ?? 'pending', $data['due_date'] ?? null),
        ]);

        return response()->json(['data' => $schedule->load(['budgetItem', 'vendor'])], 201);
    }

    public function updatePaymentSchedule(Request $request, BudgetPaymentSchedule $budgetPaymentSchedule): JsonResponse
    {
        $this->authorizeSchedule($request, $budgetPaymentSchedule);

        $data = $request->validate([
            'label' => 'sometimes|string|max:255',
            'amount' => 'nullable|numeric|min:0',
            'due_date' => 'nullable|date',
            'status' => 'nullable|in:pending,scheduled,paid,overdue',
            'paid_at' => 'nullable|date',
            'reminder_at' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        if (array_key_exists('status', $data)) {
            $data['status'] = $this->normalizedPaymentStatus($data['status'], $data['due_date'] ?? optional($budgetPaymentSchedule->due_date)->toDateString());
        }

        $budgetPaymentSchedule->update($data);

        return response()->json(['data' => $budgetPaymentSchedule->fresh()->load(['budgetItem', 'vendor'])]);
    }

    public function markPaymentPaid(Request $request, BudgetPaymentSchedule $budgetPaymentSchedule): JsonResponse
    {
        $this->authorizeSchedule($request, $budgetPaymentSchedule);

        $budgetPaymentSchedule->update([
            'status' => 'paid',
            'paid_at' => now(),
        ]);

        $item = $budgetPaymentSchedule->budgetItem;
        $paidAmount = $item->paymentSchedules()->where('status', 'paid')->sum('amount');
        $actualAmount = max((float) $item->actual_amount, (float) $item->estimated_amount);
        $item->update([
            'paid_amount' => $paidAmount,
            'payment_status' => $paidAmount >= $actualAmount ? 'paid' : ($paidAmount > 0 ? 'partial' : 'pending'),
        ]);

        return response()->json(['data' => $budgetPaymentSchedule->fresh()->load(['budgetItem', 'vendor'])]);
    }

    private function authorize(Request $request, BudgetItem $budgetItem): void
    {
        abort_unless($budgetItem->wedding_id === $this->wedding($request)->id, 403);
    }

    private function authorizeSchedule(Request $request, BudgetPaymentSchedule $schedule): void
    {
        abort_unless($schedule->wedding_id === $this->wedding($request)->id, 403);
    }

    private function authorizedVendorId(Request $request, ?int $vendorId): ?int
    {
        if (!$vendorId) {
            return null;
        }

        abort_unless($this->wedding($request)->vendors()->whereKey($vendorId)->exists(), 422, 'Vendor does not belong to this wedding.');

        return $vendorId;
    }

    private function syncCreatedSchedules($wedding, BudgetItem $item, array $schedule): void
    {
        foreach ($schedule as $payment) {
            $item->paymentSchedules()->create([
                ...$payment,
                'wedding_id' => $wedding->id,
                'vendor_id' => $item->vendor_id,
                'status' => $this->normalizedPaymentStatus($payment['status'] ?? 'pending', $payment['due_date'] ?? null),
            ]);
        }
    }

    private function summaryPayload($wedding, $items): array
    {
        $totalBudget = $wedding->settings['total_budget'] ?? 0;
        $totalEstimated = $items->sum('estimated_amount');
        $totalActual = $items->sum('actual_amount');
        $totalPaid = $items->sum('paid_amount');
        $schedules = $wedding->budgetPaymentSchedules()->with(['budgetItem', 'vendor'])->get();
        $openSchedules = $schedules->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->status !== 'paid');

        $categoryTotals = $items
            ->groupBy(fn (BudgetItem $item) => $item->category ?: 'Uncategorized')
            ->map(fn ($categoryItems) => $categoryItems->sum('actual_amount'));
        $largestCategoryName = $categoryTotals->isEmpty() ? null : $categoryTotals->sortDesc()->keys()->first();
        $largestCategoryAmount = $largestCategoryName !== null ? (float) $categoryTotals[$largestCategoryName] : 0.0;

        return [
            'total_budget'    => (float) $totalBudget,
            'total_estimated' => (float) $totalEstimated,
            'total_actual'    => (float) $totalActual,
            'total_paid'      => (float) $totalPaid,
            'balance_due'     => (float) max(0, $totalActual - $totalPaid),
            'remaining_budget' => (float) max(0, $totalBudget - $totalActual),
            'due_within_30_days' => (float) $openSchedules
                ->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->due_date && $schedule->due_date->betweenIncluded(now()->startOfDay(), now()->addDays(30)->endOfDay()))
                ->sum('amount'),
            'overdue_amount' => (float) $openSchedules
                ->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->due_date && $schedule->due_date->isPast())
                ->sum('amount'),
            'largest_expense' => $largestCategoryName !== null ? [
                'category' => $largestCategoryName,
                'amount' => $largestCategoryAmount,
                'percentage' => $totalActual > 0 ? (int) round(($largestCategoryAmount / $totalActual) * 100) : 0,
            ] : null,
            'categories' => $items->groupBy(fn (BudgetItem $item) => $item->category ?: 'Uncategorized')->map(fn ($categoryItems, $category) => [
                'category' => $category,
                'estimated' => (float) $categoryItems->sum('estimated_amount'),
                'actual' => (float) $categoryItems->sum('actual_amount'),
                'paid' => (float) $categoryItems->sum('paid_amount'),
                'balance_due' => (float) max(0, $categoryItems->sum('actual_amount') - $categoryItems->sum('paid_amount')),
                'item_count' => $categoryItems->count(),
            ])->values(),
            'next_payments' => $openSchedules
                ->reject(fn (BudgetPaymentSchedule $schedule) => $this->normalizedPaymentStatus($schedule->status, optional($schedule->due_date)->toDateString()) === 'overdue')
                ->sortBy('due_date')
                ->take(8)
                ->map(fn (BudgetPaymentSchedule $schedule) => $this->schedulePayload($schedule))
                ->values(),
            'overdue_payments' => $openSchedules
                ->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->due_date && $schedule->due_date->isPast())
                ->sortBy('due_date')
                ->map(fn (BudgetPaymentSchedule $schedule) => $this->schedulePayload($schedule))
                ->values(),
        ];
    }

    private function schedulePayload(BudgetPaymentSchedule $schedule): array
    {
        return [
            'id' => $schedule->id,
            'budget_item_id' => $schedule->budget_item_id,
            'vendor_id' => $schedule->vendor_id,
            'vendor_name' => optional($schedule->vendor)->name,
            'item_name' => optional($schedule->budgetItem)->name,
            'category' => optional($schedule->budgetItem)->category,
            'label' => $schedule->label,
            'amount' => (float) $schedule->amount,
            'due_date' => optional($schedule->due_date)->toDateString(),
            'status' => $this->normalizedPaymentStatus($schedule->status, optional($schedule->due_date)->toDateString()),
            'reminder_at' => optional($schedule->reminder_at)->toISOString(),
        ];
    }

    private function normalizedPaymentStatus(string $status, ?string $dueDate): string
    {
        if ($status === 'paid') {
            return 'paid';
        }

        if ($dueDate && now()->startOfDay()->gt(\Carbon\Carbon::parse($dueDate)->startOfDay())) {
            return 'overdue';
        }

        return $status;
    }
}
