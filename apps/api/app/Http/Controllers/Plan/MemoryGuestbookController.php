<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemoryGuestbookController extends Controller
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
        $guestbook = $this->wedding($request)->memoryGuestbook;
        return response()->json(['data' => $guestbook?->load('entries')]);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'type' => 'nullable|in:physical,digital,both',
            'vendor_name' => 'nullable|string|max:255',
            'setup_location' => 'nullable|string|max:255',
            'instructions' => 'nullable|string',
            'status' => 'nullable|string|max:100',
            'digital_enabled' => 'nullable|boolean',
        ]);

        $guestbook = $wedding->memoryGuestbook()->firstOrCreate([]);
        $guestbook->update($data);

        return response()->json(['data' => $guestbook->fresh()->load('entries')]);
    }
}
