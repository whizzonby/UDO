<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HoneymoonController extends Controller
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

    public function show(Request $request): JsonResponse
    {
        $trip = $this->wedding($request)->honeymoonTrip;
        return response()->json(['data' => $trip?->load('items')]);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'destination' => 'nullable|string|max:255',
            'departure_date' => 'nullable|date',
            'return_date' => 'nullable|date',
            'status' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
            'checklist' => 'nullable|array',
        ]);

        $trip = $wedding->honeymoonTrip()->firstOrCreate([]);
        $trip->update($data);

        return response()->json(['data' => $trip->fresh()->load('items')]);
    }
}
