<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemoryMusicController extends Controller
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
        return response()->json(['data' => $this->wedding($request)->memoryMusicMoment]);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'first_dance_song' => 'nullable|string|max:255',
            'parent_dance_song' => 'nullable|string|max:255',
            'entrance_music' => 'nullable|string|max:255',
            'exit_song' => 'nullable|string|max:255',
            'cake_cutting_song' => 'nullable|string|max:255',
            'bouquet_toss_song' => 'nullable|string|max:255',
            'other_moments' => 'nullable|array',
            'other_moments.*.label' => 'required_with:other_moments|string|max:255',
            'other_moments.*.song' => 'nullable|string|max:255',
        ]);

        $music = $wedding->memoryMusicMoment()->firstOrCreate([]);
        $music->update($data);

        return response()->json(['data' => $music->fresh()]);
    }
}
