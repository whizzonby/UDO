<?php

namespace App\Http\Controllers;

use App\Models\LiveUpdate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LiveController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $updates = $this->wedding($request)
            ->liveUpdates()
            ->orderByDesc('pinned')
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['data' => $updates]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'type'              => 'nullable|in:general,schedule,venue,announcement',
            'title'             => 'required|string|max:255',
            'body'              => 'nullable|string',
            'image_url'         => 'nullable|url',
            'pinned'            => 'nullable|boolean',
            'visible_to_guests' => 'nullable|boolean',
            'bride_only'        => 'nullable|boolean',
            'event_time'        => 'nullable|date_format:H:i',
        ]);

        $update = $wedding->liveUpdates()->create([
            ...$data,
            'type' => $data['type'] ?? 'general',
        ]);

        // Broadcast via Reverb if available
        // broadcast(new LiveUpdatePosted($update))->toOthers();

        return response()->json(['data' => $update], 201);
    }

    public function update(Request $request, LiveUpdate $liveUpdate): JsonResponse
    {
        abort_unless($liveUpdate->wedding_id === $this->wedding($request)->id, 403);

        $data = $request->validate([
            'type'              => 'nullable|in:general,schedule,venue,announcement',
            'title'             => 'sometimes|string|max:255',
            'body'              => 'nullable|string',
            'image_url'         => 'nullable|url',
            'pinned'            => 'nullable|boolean',
            'visible_to_guests' => 'nullable|boolean',
            'bride_only'        => 'nullable|boolean',
            'event_time'        => 'nullable|date_format:H:i',
        ]);

        $liveUpdate->update($data);

        return response()->json(['data' => $liveUpdate->fresh()]);
    }

    public function destroy(Request $request, LiveUpdate $liveUpdate): JsonResponse
    {
        abort_unless($liveUpdate->wedding_id === $this->wedding($request)->id, 403);
        $liveUpdate->delete();
        return response()->json(null, 204);
    }
}
