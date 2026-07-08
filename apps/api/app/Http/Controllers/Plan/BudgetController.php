<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\BudgetItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $items = $wedding->budgetItems()->with('vendor')->orderBy('category')->get();

        $totalBudget = $wedding->settings['total_budget'] ?? 0;
        $totalEstimated = $items->sum('estimated_amount');
        $totalActual = $items->sum('actual_amount');
        $totalPaid = $items->sum('paid_amount');

        return response()->json([
            'data' => $items,
            'summary' => [
                'total_budget'    => (float) $totalBudget,
                'total_estimated' => (float) $totalEstimated,
                'total_actual'    => (float) $totalActual,
                'total_paid'      => (float) $totalPaid,
                'balance_due'     => (float) ($totalActual - $totalPaid),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'total_budget'   => 'nullable|numeric|min:0',
            'name'           => 'required|string|max:255',
            'category'       => 'nullable|string|max:100',
            'vendor_id'      => 'nullable|integer',
            'estimated_amount' => 'nullable|numeric|min:0',
            'actual_amount'    => 'nullable|numeric|min:0',
            'paid_amount'      => 'nullable|numeric|min:0',
            'payment_status'   => 'nullable|in:pending,partial,paid',
            'due_date'         => 'nullable|date',
            'notes'            => 'nullable|string',
        ]);

        if (isset($data['total_budget'])) {
            $settings = $wedding->settings ?? [];
            $settings['total_budget'] = $data['total_budget'];
            $wedding->update(['settings' => $settings]);
            unset($data['total_budget']);
        }

        $item = $wedding->budgetItems()->create($data);

        return response()->json(['data' => $item], 201);
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
            'vendor_id'      => 'nullable|integer',
            'estimated_amount' => 'nullable|numeric|min:0',
            'actual_amount'    => 'nullable|numeric|min:0',
            'paid_amount'      => 'nullable|numeric|min:0',
            'payment_status'   => 'nullable|in:pending,partial,paid',
            'due_date'       => 'nullable|date',
            'notes'          => 'nullable|string',
        ]);

        $budgetItem->update($data);

        return response()->json(['data' => $budgetItem->fresh()->load('vendor')]);
    }

    public function destroy(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        $this->authorize($request, $budgetItem);
        $budgetItem->delete();
        return response()->json(null, 204);
    }

    private function authorize(Request $request, BudgetItem $budgetItem): void
    {
        abort_unless($budgetItem->wedding_id === $this->wedding($request)->id, 403);
    }
}
