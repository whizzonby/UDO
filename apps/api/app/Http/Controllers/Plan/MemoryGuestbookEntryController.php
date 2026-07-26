<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\MemoryGuestbookEntry;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemoryGuestbookEntryController extends Controller
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

    public function update(Request $request, MemoryGuestbookEntry $entry): JsonResponse
    {
        $this->authorizeEntry($request, $entry);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'approved' => 'required|boolean',
        ]);

        $entry->update($data);

        return response()->json(['data' => $entry->fresh()]);
    }

    public function destroy(Request $request, MemoryGuestbookEntry $entry): JsonResponse
    {
        $this->authorizeEntry($request, $entry);
        $this->ensureCanManagePlan($request);
        $entry->delete();
        return response()->json(null, 204);
    }

    private function authorizeEntry(Request $request, MemoryGuestbookEntry $entry): void
    {
        abort_unless($entry->guestbook->wedding_id === $this->wedding($request)->id, 403);
    }
}
