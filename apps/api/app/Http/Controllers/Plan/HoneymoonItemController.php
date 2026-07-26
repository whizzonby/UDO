<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\HoneymoonItem;
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
            'type' => "$req|in:flight,accommodation,activity",
            'title' => "$req|string|max:255",
            'date' => 'nullable|date',
            'cost' => 'nullable|numeric|min:0',
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

        return response()->json(['data' => $item], 201);
    }

    public function update(Request $request, HoneymoonItem $honeymoonItem): JsonResponse
    {
        $this->authorizeItem($request, $honeymoonItem);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(partial: true));
        $honeymoonItem->update($data);

        return response()->json(['data' => $honeymoonItem->fresh()]);
    }

    public function destroy(Request $request, HoneymoonItem $honeymoonItem): JsonResponse
    {
        $this->authorizeItem($request, $honeymoonItem);
        $this->ensureCanManagePlan($request);
        $honeymoonItem->delete();
        return response()->json(null, 204);
    }

    private function authorizeItem(Request $request, HoneymoonItem $honeymoonItem): void
    {
        $wedding = $this->wedding($request);
        abort_unless($honeymoonItem->trip->wedding_id === $wedding->id, 403);
    }
}
