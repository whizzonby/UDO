<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemoryPhotoBoothController extends Controller
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
        return response()->json(['data' => $this->wedding($request)->memoryPhotoBooth]);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'vendor_name' => 'nullable|string|max:255',
            'setup_time' => 'nullable|string|max:100',
            'location' => 'nullable|string|max:255',
            'props' => 'nullable|string',
            'backdrop' => 'nullable|string|max:255',
            'sharing_method' => 'nullable|string|max:255',
            'guest_access' => 'nullable|boolean',
            'status' => 'nullable|string|max:100',
        ]);

        $photoBooth = $wedding->memoryPhotoBooth()->firstOrCreate([]);
        $photoBooth->update($data);

        return response()->json(['data' => $photoBooth->fresh()]);
    }
}
