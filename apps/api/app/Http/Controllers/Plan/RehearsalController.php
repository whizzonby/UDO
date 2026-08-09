<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Rehearsal;
use App\Models\TimelineItem;
use App\Models\Wedding;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RehearsalController extends Controller
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

    private function rules(bool $isUpdate): array
    {
        return [
            'title'               => ($isUpdate ? 'sometimes' : 'required') . '|string|max:255',
            'color'               => 'nullable|string|max:20',
            'location'            => 'nullable|string|max:255',
            'location_place_id'   => 'nullable|string|max:255',
            'description'         => 'nullable|string',
            'event_date'          => ($isUpdate ? 'sometimes' : 'required') . '|date',
            'start_time'          => 'nullable|date_format:H:i',
            'end_time'            => 'nullable|date_format:H:i',
            'timezone'            => 'nullable|string|max:100',
            'audience'            => 'nullable|in:all,wedding_party,family,travelling,vip,vendors,selected,private',
            'audience_groups'     => 'nullable|array',
            'audience_groups.*'   => 'string|in:all,wedding_party,family,travelling,vip,vendors,selected,private',
            'attendee_guest_ids'  => 'nullable|array',
            'attendee_guest_ids.*' => 'integer|exists:guests,id',
            'dress_code'          => 'nullable|string|max:100',
            'bring_items'         => 'nullable|array',
            'bring_items.*'       => 'string|max:255',
            'schedule_items'      => 'nullable|array',
            'schedule_items.*.time'        => 'nullable|string|max:20',
            'schedule_items.*.title'       => 'required_with:schedule_items|string|max:255',
            'schedule_items.*.description' => 'nullable|string',
            'notes'               => 'nullable|string',
            'add_to_timeline'     => 'nullable|boolean',
        ];
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)->rehearsals()->get();
        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(false));

        $rehearsal = $wedding->rehearsals()->create($data);
        $this->syncTimelineItem($wedding, $rehearsal);

        return response()->json(['data' => $rehearsal->fresh()], 201);
    }

    public function show(Request $request, Rehearsal $rehearsal): JsonResponse
    {
        $this->authorize($request, $rehearsal);
        return response()->json(['data' => $rehearsal]);
    }

    public function update(Request $request, Rehearsal $rehearsal): JsonResponse
    {
        $this->authorize($request, $rehearsal);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(true));

        $rehearsal->update($data);
        $this->syncTimelineItem($this->wedding($request), $rehearsal);

        return response()->json(['data' => $rehearsal->fresh()]);
    }

    public function destroy(Request $request, Rehearsal $rehearsal): JsonResponse
    {
        $this->authorize($request, $rehearsal);
        $this->ensureCanManagePlan($request);

        if ($rehearsal->timeline_item_id) {
            TimelineItem::whereKey($rehearsal->timeline_item_id)->delete();
        }
        $rehearsal->delete();

        return response()->json(null, 204);
    }

    private function authorize(Request $request, Rehearsal $rehearsal): void
    {
        abort_unless($rehearsal->wedding_id === $this->wedding($request)->id, 403);
    }

    /**
     * Keeps the rehearsal's optional Day Timeline entry in sync with the
     * add_to_timeline toggle: creates it the first time it's turned on,
     * pushes field changes while it stays on, and removes it (rather than
     * leaving an orphaned entry) when turned off.
     */
    private function syncTimelineItem(Wedding $wedding, Rehearsal $rehearsal): void
    {
        if (! $rehearsal->add_to_timeline) {
            if ($rehearsal->timeline_item_id) {
                TimelineItem::whereKey($rehearsal->timeline_item_id)->delete();
                $rehearsal->update(['timeline_item_id' => null]);
            }
            return;
        }

        $timelineData = [
            'title' => $rehearsal->title,
            'event_type' => 'rehearsal',
            'event_date' => $rehearsal->event_date,
            'start_time' => $rehearsal->start_time,
            'end_time' => $rehearsal->end_time,
            'location' => $rehearsal->location,
            'description' => $rehearsal->description,
            'notes' => $rehearsal->notes,
        ];

        if ($rehearsal->timeline_item_id) {
            TimelineItem::whereKey($rehearsal->timeline_item_id)->update($timelineData);
            return;
        }

        $timelineItem = $wedding->timelineItems()->create($timelineData);
        $rehearsal->update(['timeline_item_id' => $timelineItem->id]);
    }
}
