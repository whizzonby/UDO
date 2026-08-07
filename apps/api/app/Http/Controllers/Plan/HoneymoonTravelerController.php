<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\HoneymoonTraveler;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HoneymoonTravelerController extends Controller
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

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $trip = $wedding->honeymoonTrip()->firstOrCreate([]);
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'role' => 'nullable|string|max:100',
        ]);
        $traveler = $trip->travelers()->create($data);

        return response()->json(['data' => $traveler], 201);
    }

    public function update(Request $request, HoneymoonTraveler $honeymoonTraveler): JsonResponse
    {
        $this->authorizeTraveler($request, $honeymoonTraveler);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'role' => 'nullable|string|max:100',
        ]);
        $honeymoonTraveler->update($data);

        return response()->json(['data' => $honeymoonTraveler->fresh()]);
    }

    public function destroy(Request $request, HoneymoonTraveler $honeymoonTraveler): JsonResponse
    {
        $this->authorizeTraveler($request, $honeymoonTraveler);
        $this->ensureCanManagePlan($request);
        $honeymoonTraveler->delete();
        return response()->json(null, 204);
    }

    private function authorizeTraveler(Request $request, HoneymoonTraveler $honeymoonTraveler): void
    {
        $wedding = $this->wedding($request);
        abort_unless($honeymoonTraveler->trip->wedding_id === $wedding->id, 403);
    }
}
