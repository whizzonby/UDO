<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\BudgetItem;
use App\Models\HoneymoonItem;
use App\Models\Wedding;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HoneymoonItemController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManagePlan(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_plan'), 403);
    }

    private function rules(bool $partial = false): array
    {
        $req = $partial ? 'sometimes' : 'required';
        return [
            'type' => "$req|in:flight,accommodation,activity,other",
            'status' => 'nullable|in:pending,confirmed',
            'title' => "$req|string|max:255",
            'date' => 'nullable|date',
            'time' => 'nullable|date_format:H:i',
            'cost' => 'nullable|numeric|min:0',
            'traveler_ids' => 'nullable|array',
            'traveler_ids.*' => 'integer|exists:honeymoon_travelers,id',
            'details' => 'nullable|array',
        ];
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $trip = $wedding->honeymoonTrip()->firstOrCreate([]);
        $data = $request->validate($this->rules());
        $item = $trip->items()->create($data);
        $this->syncBudgetItem($wedding, $item);

        return response()->json(['data' => $item->fresh()], 201);
    }

    public function update(Request $request, HoneymoonItem $honeymoonItem): JsonResponse
    {
        $this->authorizeItem($request, $honeymoonItem);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(partial: true));
        $honeymoonItem->update($data);
        $this->syncBudgetItem($this->wedding($request), $honeymoonItem);

        return response()->json(['data' => $honeymoonItem->fresh()]);
    }

    public function destroy(Request $request, HoneymoonItem $honeymoonItem): JsonResponse
    {
        $this->authorizeItem($request, $honeymoonItem);
        $this->ensureCanManagePlan($request);

        if ($honeymoonItem->budget_item_id) {
            BudgetItem::whereKey($honeymoonItem->budget_item_id)->delete();
        }
        $honeymoonItem->delete();

        return response()->json(null, 204);
    }

    private function authorizeItem(Request $request, HoneymoonItem $honeymoonItem): void
    {
        $wedding = $this->wedding($request);
        abort_unless($honeymoonItem->trip->wedding_id === $wedding->id, 403);
    }

    /**
     * Mirrors an item's cost onto a real BudgetItem (category "Honeymoon") so
     * honeymoon spending shows up in the wedding's actual budget instead of
     * being a disconnected number — same create/sync/delete-on-clear pattern
     * used for Rehearsal's optional linked TimelineItem.
     */
    private function syncBudgetItem(Wedding $wedding, HoneymoonItem $item): void
    {
        if ($item->cost === null) {
            if ($item->budget_item_id) {
                BudgetItem::whereKey($item->budget_item_id)->delete();
                $item->update(['budget_item_id' => null]);
            }
            return;
        }

        if ($item->budget_item_id) {
            BudgetItem::whereKey($item->budget_item_id)->update([
                'name' => $item->title,
                'estimated_amount' => $item->cost,
            ]);
            return;
        }

        $budgetItem = $wedding->budgetItems()->create([
            'name' => $item->title,
            'category' => 'Honeymoon',
            'estimated_amount' => $item->cost,
        ]);
        $item->update(['budget_item_id' => $budgetItem->id]);
    }
}
