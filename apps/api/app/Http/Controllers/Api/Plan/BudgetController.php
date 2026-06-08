<?php

namespace App\Http\Controllers\Api\Plan;

use App\Http\Controllers\Controller;
use App\Http\Requests\Plan\StoreBudgetItemRequest;
use App\Http\Requests\Plan\UpdateBudgetItemRequest;
use App\Http\Resources\BudgetItemResource;
use App\Models\BudgetItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class BudgetController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        return BudgetItemResource::collection($wedding->budgetItems()->with('vendor')->get());
    }

    public function store(StoreBudgetItemRequest $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->firstOrFail();
        $item    = $wedding->budgetItems()->create($request->validated());

        return response()->json(new BudgetItemResource($item->load('vendor')), 201);
    }

    public function update(UpdateBudgetItemRequest $request, BudgetItem $budgetItem): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $budgetItem->wedding_id)->exists(),
            403
        );

        $budgetItem->update($request->validated());

        return response()->json(new BudgetItemResource($budgetItem->fresh()->load('vendor')));
    }

    public function destroy(Request $request, BudgetItem $budgetItem): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $budgetItem->wedding_id)->exists(),
            403
        );

        $budgetItem->delete();

        return response()->json(['message' => 'Budget item deleted.']);
    }
}
