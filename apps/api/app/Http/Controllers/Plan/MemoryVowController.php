<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\MemoryVow;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MemoryVowController extends Controller
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

        $vows = $wedding->memoryVows()
            ->when(! $isCoreCouple, fn ($q) => $q->where('is_private', false))
            ->get();

        return response()->json(['data' => $vows]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'draft_text' => 'nullable|string',
            'is_private' => 'nullable|boolean',
            'is_final' => 'nullable|boolean',
            'printing_status' => 'nullable|string|max:100',
            'has_backup' => 'nullable|boolean',
            'file' => 'nullable|file|mimes:pdf,doc,docx,txt|max:10240',
        ]);

        // Default explicitly (rather than relying on the DB column default) so
        // the response reflects the real value instead of a stale in-memory
        // null for a column the request didn't set.
        $data['is_private'] = $data['is_private'] ?? true;

        if ($request->hasFile('file')) {
            $data['file_path'] = Storage::url($request->file('file')->store("weddings/{$wedding->id}/memories", 'public'));
        }
        unset($data['file']);

        $vow = $wedding->memoryVows()->create($data);

        return response()->json(['data' => $vow], 201);
    }

    public function update(Request $request, MemoryVow $memoryVow): JsonResponse
    {
        $this->authorizeVow($request, $memoryVow);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title' => 'sometimes|string|max:255',
            'draft_text' => 'nullable|string',
            'is_private' => 'nullable|boolean',
            'is_final' => 'nullable|boolean',
            'printing_status' => 'nullable|string|max:100',
            'has_backup' => 'nullable|boolean',
            'file' => 'nullable|file|mimes:pdf,doc,docx,txt|max:10240',
        ]);

        if ($request->hasFile('file')) {
            $data['file_path'] = Storage::url($request->file('file')->store("weddings/{$memoryVow->wedding_id}/memories", 'public'));
        }
        unset($data['file']);

        $memoryVow->update($data);

        return response()->json(['data' => $memoryVow->fresh()]);
    }

    public function destroy(Request $request, MemoryVow $memoryVow): JsonResponse
    {
        $this->authorizeVow($request, $memoryVow);
        $this->ensureCanManagePlan($request);
        $memoryVow->delete();
        return response()->json(null, 204);
    }

    public function markViewed(Request $request, MemoryVow $memoryVow): JsonResponse
    {
        $this->authorizeVow($request, $memoryVow);
        if (! $memoryVow->viewed_at) {
            $memoryVow->update(['viewed_at' => now()]);
        }
        return response()->json(['data' => $memoryVow->fresh()]);
    }

    private function authorizeVow(Request $request, MemoryVow $memoryVow): void
    {
        abort_unless($memoryVow->wedding_id === $this->wedding($request)->id, 403);
    }
}
