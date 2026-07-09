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

    /**
     * Aggregates everything the Today tab needs into one response so it
     * can be polled every ~20s without firing six separate requests.
     */
    public function today(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $now = now();

        $current = null;
        $next = null;
        foreach ($wedding->timelineItems as $item) {
            if (! $item->event_date || ! $item->start_time) {
                continue;
            }
            $start = \Carbon\Carbon::parse($item->event_date->toDateString() . ' ' . $item->start_time);
            $end = $item->end_time
                ? \Carbon\Carbon::parse($item->event_date->toDateString() . ' ' . $item->end_time)
                : $start->copy()->addMinutes($item->duration_minutes ?? 30);

            if ($now->between($start, $end)) {
                $current = $item;
            } elseif ($start->greaterThan($now) && ! $next) {
                $next = $item;
            }
        }

        return response()->json(['data' => [
            'guests' => [
                'confirmed' => $wedding->guests()->where('attending_status', 'yes')->count(),
                'invited'   => $wedding->guests()->count(),
            ],
            'vendors' => [
                'confirmed' => $wedding->vendors()->where('booking_status', 'confirmed')->count(),
                'total'     => $wedding->vendors()->count(),
            ],
            'gallery' => [
                'photos' => $wedding->galleryAssets()->count(),
            ],
            'timeline' => [
                'current' => $current,
                'next'    => $next,
            ],
            'recent_updates'     => $wedding->liveUpdates()->orderByDesc('created_at')->limit(5)->get(),
            'emergency_contacts' => $wedding->weddingPartyEmergencyContacts,
        ]]);
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
            'type'       => $data['type'] ?? 'general',
            'created_by' => $request->user()->id,
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
