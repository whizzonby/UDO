<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\FoodServiceItem;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FoodServiceItemController extends Controller
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

    public function index(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->wedding($request)->foodServiceItems()->get()]);
    }

    private function rules(bool $partial = false): array
    {
        $req = $partial ? 'sometimes' : 'required';
        return [
            'event_category' => "$req|string|max:255",
            'service_category' => 'nullable|string|max:255',
            'service_type' => 'nullable|string|max:255',
            'event_date' => 'nullable|date',
            'start_time' => 'nullable|date_format:H:i',
            'end_time' => 'nullable|date_format:H:i',
            'location' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'assigned_to' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'status' => 'nullable|in:planned,ordered,scheduled,in_progress,ready,completed,cancelled,requires_review,delayed',
            'priority' => 'nullable|in:low,normal,high,critical',
        ];
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules());
        $item = $wedding->foodServiceItems()->create($data);

        return response()->json(['data' => $item], 201);
    }

    public function update(Request $request, FoodServiceItem $foodServiceItem): JsonResponse
    {
        $this->authorizeItem($request, $foodServiceItem);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(partial: true));
        $foodServiceItem->update($data);

        return response()->json(['data' => $foodServiceItem->fresh()]);
    }

    public function destroy(Request $request, FoodServiceItem $foodServiceItem): JsonResponse
    {
        $this->authorizeItem($request, $foodServiceItem);
        $this->ensureCanManagePlan($request);
        $foodServiceItem->delete();
        return response()->json(null, 204);
    }

    private function authorizeItem(Request $request, FoodServiceItem $foodServiceItem): void
    {
        abort_unless($foodServiceItem->wedding_id === $this->wedding($request)->id, 403);
    }
}
