<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\TimelineItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TimelineController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)
            ->timelineItems()
            ->orderBy('event_date')
            ->orderBy('start_time')
            ->get();

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'title'             => 'required|string|max:255',
            'event_type'        => 'nullable|string|max:100',
            'event_date'        => 'nullable|date',
            'start_time'        => 'nullable|date_format:H:i',
            'end_time'          => 'nullable|date_format:H:i',
            'duration_minutes'  => 'nullable|integer|min:1',
            'location'          => 'nullable|string|max:255',
            'description'       => 'nullable|string',
            'assigned_vendors'  => 'nullable|array',
            'guest_groups'      => 'nullable|array',
            'visible_to_guests' => 'nullable|boolean',
            'notes'             => 'nullable|string',
            'sort_order'        => 'nullable|integer',
        ]);

        $item = $wedding->timelineItems()->create($data);

        return response()->json(['data' => $item], 201);
    }

    public function show(Request $request, TimelineItem $timelineItem): JsonResponse
    {
        $this->authorize($request, $timelineItem);
        return response()->json(['data' => $timelineItem]);
    }

    public function update(Request $request, TimelineItem $timelineItem): JsonResponse
    {
        $this->authorize($request, $timelineItem);

        $data = $request->validate([
            'title'             => 'sometimes|string|max:255',
            'event_type'        => 'nullable|string|max:100',
            'event_date'        => 'nullable|date',
            'start_time'        => 'nullable|date_format:H:i',
            'end_time'          => 'nullable|date_format:H:i',
            'duration_minutes'  => 'nullable|integer|min:1',
            'location'          => 'nullable|string|max:255',
            'description'       => 'nullable|string',
            'assigned_vendors'  => 'nullable|array',
            'guest_groups'      => 'nullable|array',
            'visible_to_guests' => 'nullable|boolean',
            'notes'             => 'nullable|string',
            'sort_order'        => 'nullable|integer',
        ]);

        $timelineItem->update($data);

        return response()->json(['data' => $timelineItem->fresh()]);
    }

    public function destroy(Request $request, TimelineItem $timelineItem): JsonResponse
    {
        $this->authorize($request, $timelineItem);
        $timelineItem->delete();
        return response()->json(null, 204);
    }

    private function authorize(Request $request, TimelineItem $timelineItem): void
    {
        abort_unless($timelineItem->wedding_id === $this->wedding($request)->id, 403);
    }
}
