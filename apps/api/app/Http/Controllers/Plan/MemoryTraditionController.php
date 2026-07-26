<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\MemoryTradition;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemoryTraditionController extends Controller
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
        $wedding = $this->wedding($request);
        $isCoreCouple = app(WeddingAccessService::class)->isCoreCouple($request->user(), $wedding);

        $traditions = $wedding->memoryTraditions()
            ->when(! $isCoreCouple, fn ($q) => $q->where('visibility', 'shared'))
            ->get();

        return response()->json(['data' => $traditions]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'person_responsible' => 'nullable|string|max:255',
            'required_items' => 'nullable|string',
            'timing' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'visibility' => 'nullable|in:shared,private',
        ]);

        $tradition = $wedding->memoryTraditions()->create($data);

        return response()->json(['data' => $tradition], 201);
    }

    public function update(Request $request, MemoryTradition $memoryTradition): JsonResponse
    {
        $this->authorizeTradition($request, $memoryTradition);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'person_responsible' => 'nullable|string|max:255',
            'required_items' => 'nullable|string',
            'timing' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'visibility' => 'nullable|in:shared,private',
        ]);

        $memoryTradition->update($data);

        return response()->json(['data' => $memoryTradition->fresh()]);
    }

    public function destroy(Request $request, MemoryTradition $memoryTradition): JsonResponse
    {
        $this->authorizeTradition($request, $memoryTradition);
        $this->ensureCanManagePlan($request);
        $memoryTradition->delete();
        return response()->json(null, 204);
    }

    private function authorizeTradition(Request $request, MemoryTradition $memoryTradition): void
    {
        abort_unless($memoryTradition->wedding_id === $this->wedding($request)->id, 403);
    }
}
