<?php

namespace App\Http\Controllers;

use App\Models\LiveUpdate;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LiveController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManageLive(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_live'), 403);
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
        $unresolvedIncidents = $wedding->liveUpdates()
            ->whereIn('type', ['incident', 'alert'])
            ->where('status', '!=', 'resolved')
            ->orderByDesc('pinned')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get();
        $todayTimelineItems = $wedding->timelineItems->filter(
            fn ($item) => $item->event_date && $item->event_date->isToday()
        )->values();
        $travellingGuests = $wedding->guests()->where('travel_required', true)->get();
        $todayArrivals = $travellingGuests->filter(fn ($guest) => $guest->arrival_date && $guest->arrival_date->isToday())->values();
        $confirmedVendors = $wedding->vendors()->where('booking_status', 'confirmed')->get();
        $vipGuests = $wedding->guests()->where('vip_flag', true)->get();
        $vipAttention = $vipGuests
            ->filter(fn ($guest) => $guest->attending_status !== 'no' && (
                ! $guest->seating_assignment_id ||
                ($guest->travel_required && (! $guest->arrival_date || ! $guest->hotel_assignment_id || ! $guest->transport_assignment_id))
            ))
            ->map(fn ($guest) => [
                'id' => $guest->id,
                'name' => $guest->full_name,
                'issues' => array_values(array_filter([
                    ! $guest->seating_assignment_id ? 'seating' : null,
                    $guest->travel_required && ! $guest->arrival_date ? 'arrival' : null,
                    $guest->travel_required && ! $guest->hotel_assignment_id ? 'accommodation' : null,
                    $guest->travel_required && ! $guest->transport_assignment_id ? 'transport' : null,
                ])),
            ])
            ->values();
        $status = $unresolvedIncidents->isNotEmpty()
            ? 'attention'
            : ($current ? 'live' : ($next ? 'ready' : 'quiet'));

        return response()->json(['data' => [
            'status' => [
                'state' => $status,
                'label' => $status === 'attention' ? 'Needs attention' : ($status === 'live' ? 'In progress' : 'Ready'),
                'message' => $unresolvedIncidents->isNotEmpty()
                    ? 'There are open live issues to resolve.'
                    : 'No action needed right now.',
                'unresolved_incidents' => $unresolvedIncidents->count(),
            ],
            'guests' => [
                'confirmed' => $wedding->guests()->where('attending_status', 'yes')->count(),
                'invited'   => $wedding->guests()->count(),
            ],
            'arrivals' => [
                'travelling_guests' => $travellingGuests->count(),
                'arriving_today' => $todayArrivals->count(),
                'missing_arrival_info' => $travellingGuests->filter(fn ($guest) => ! $guest->arrival_date || ! $guest->arrival_time)->count(),
                'vip_attention_count' => $vipAttention->count(),
                'checked_in_count' => $todayArrivals->filter(fn ($guest) => $guest->checked_in_at)->count(),
                'arriving_today_guests' => $todayArrivals->map(fn ($guest) => [
                    'id' => $guest->id,
                    'name' => $guest->full_name,
                    'arrival_time' => $guest->arrival_time,
                    'checked_in_at' => $guest->checked_in_at,
                ])->values(),
            ],
            'vip_attention' => $vipAttention,
            'incidents' => $unresolvedIncidents,
            'vendors' => [
                'confirmed' => $confirmedVendors->count(),
                'total'     => $wedding->vendors()->count(),
                'checked_in_count' => $confirmedVendors->filter(fn ($vendor) => $vendor->checked_in_at)->count(),
                'roster' => $confirmedVendors->map(fn ($vendor) => [
                    'id' => $vendor->id,
                    'name' => $vendor->name,
                    'category' => $vendor->category,
                    'checked_in_at' => $vendor->checked_in_at,
                ])->values(),
            ],
            'transport' => [
                'arranged' => $travellingGuests->filter(fn ($guest) => $guest->transport_assignment_id)->count(),
                'total_requiring' => $travellingGuests->count(),
            ],
            'gallery' => [
                'photos' => $wedding->galleryAssets()->count(),
            ],
            'timeline' => [
                'current' => $current,
                'next'    => $next,
                'today_items' => $todayTimelineItems,
            ],
            'recent_updates'     => $wedding->liveUpdates()->orderByDesc('created_at')->limit(5)->get(),
            'emergency_contacts' => $wedding->weddingPartyEmergencyContacts,
        ]]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageLive($request);

        $data = $request->validate([
            'type'              => 'nullable|in:general,schedule,venue,announcement,incident,alert,vip,arrival,logistics',
            'severity'          => 'nullable|in:info,low,medium,high,critical',
            'audience'          => 'nullable|in:all,guests,team,vip,private',
            'status'            => 'nullable|in:open,monitoring,resolved',
            'title'             => 'required|string|max:255',
            'body'              => 'nullable|string',
            'image_url'         => 'nullable|url',
            'pinned'            => 'nullable|boolean',
            'visible_to_guests' => 'nullable|boolean',
            'bride_only'        => 'nullable|boolean',
            'requires_action'   => 'nullable|boolean',
            'event_time'        => 'nullable|date_format:H:i',
        ]);

        $update = $wedding->liveUpdates()->create([
            ...$data,
            'type'       => $data['type'] ?? 'general',
            'severity'   => $data['severity'] ?? 'info',
            'audience'   => $data['audience'] ?? 'all',
            'status'     => $data['status'] ?? 'open',
            'created_by' => $request->user()->id,
        ]);

        // Broadcast via Reverb if available
        // broadcast(new LiveUpdatePosted($update))->toOthers();

        return response()->json(['data' => $update], 201);
    }

    public function update(Request $request, LiveUpdate $liveUpdate): JsonResponse
    {
        abort_unless($liveUpdate->wedding_id === $this->wedding($request)->id, 403);
        $this->ensureCanManageLive($request);

        $data = $request->validate([
            'type'              => 'nullable|in:general,schedule,venue,announcement,incident,alert,vip,arrival,logistics',
            'severity'          => 'nullable|in:info,low,medium,high,critical',
            'audience'          => 'nullable|in:all,guests,team,vip,private',
            'status'            => 'nullable|in:open,monitoring,resolved',
            'title'             => 'sometimes|string|max:255',
            'body'              => 'nullable|string',
            'image_url'         => 'nullable|url',
            'pinned'            => 'nullable|boolean',
            'visible_to_guests' => 'nullable|boolean',
            'bride_only'        => 'nullable|boolean',
            'requires_action'   => 'nullable|boolean',
            'event_time'        => 'nullable|date_format:H:i',
        ]);
        if (($data['status'] ?? null) === 'resolved') {
            $data['resolved_at'] = now();
            $data['requires_action'] = false;
        }

        $liveUpdate->update($data);

        return response()->json(['data' => $liveUpdate->fresh()]);
    }

    public function resolve(Request $request, LiveUpdate $liveUpdate): JsonResponse
    {
        abort_unless($liveUpdate->wedding_id === $this->wedding($request)->id, 403);
        $this->ensureCanManageLive($request);

        $liveUpdate->update([
            'status' => 'resolved',
            'requires_action' => false,
            'resolved_at' => now(),
        ]);

        return response()->json(['data' => $liveUpdate->fresh()]);
    }

    public function destroy(Request $request, LiveUpdate $liveUpdate): JsonResponse
    {
        abort_unless($liveUpdate->wedding_id === $this->wedding($request)->id, 403);
        $this->ensureCanManageLive($request);
        $liveUpdate->delete();
        return response()->json(null, 204);
    }
}
