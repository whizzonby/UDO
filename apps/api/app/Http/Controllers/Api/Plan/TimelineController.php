<?php

namespace App\Http\Controllers\Api\Plan;

use App\Http\Controllers\Controller;
use App\Http\Resources\TimelineEventResource;
use App\Models\TimelineEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TimelineController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        return TimelineEventResource::collection($wedding->timelineEvents()->get());
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title'          => ['required', 'string', 'max:255'],
            'description'    => ['nullable', 'string'],
            'event_date'     => ['required', 'date'],
            'start_time'     => ['nullable', 'date_format:H:i'],
            'end_time'       => ['nullable', 'date_format:H:i'],
            'location'       => ['nullable', 'string', 'max:255'],
            'color'          => ['nullable', 'string', 'max:7'],
            'is_wedding_day' => ['boolean'],
            'sort_order'     => ['nullable', 'integer'],
        ]);

        $wedding = $request->user()->weddings()->firstOrFail();
        $event   = $wedding->timelineEvents()->create([
            ...$request->only([
                'title', 'description', 'event_date', 'start_time',
                'end_time', 'location', 'color', 'is_wedding_day',
            ]),
            'sort_order' => $request->sort_order ?? ($wedding->timelineEvents()->max('sort_order') + 1),
        ]);

        return response()->json(new TimelineEventResource($event), 201);
    }

    public function update(Request $request, TimelineEvent $timelineEvent): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $timelineEvent->wedding_id)->exists(),
            403
        );

        $request->validate([
            'title'          => ['sometimes', 'string', 'max:255'],
            'description'    => ['nullable', 'string'],
            'event_date'     => ['sometimes', 'date'],
            'start_time'     => ['nullable', 'date_format:H:i'],
            'end_time'       => ['nullable', 'date_format:H:i'],
            'location'       => ['nullable', 'string', 'max:255'],
            'color'          => ['nullable', 'string', 'max:7'],
            'is_wedding_day' => ['boolean'],
            'sort_order'     => ['nullable', 'integer'],
        ]);

        $timelineEvent->update($request->only([
            'title', 'description', 'event_date', 'start_time',
            'end_time', 'location', 'color', 'is_wedding_day', 'sort_order',
        ]));

        return response()->json(new TimelineEventResource($timelineEvent->fresh()));
    }

    public function destroy(Request $request, TimelineEvent $timelineEvent): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $timelineEvent->wedding_id)->exists(),
            403
        );

        $timelineEvent->delete();

        return response()->json(['message' => 'Event deleted.']);
    }
}
