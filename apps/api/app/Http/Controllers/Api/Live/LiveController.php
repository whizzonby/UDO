<?php

namespace App\Http\Controllers\Api\Live;

use App\Http\Controllers\Controller;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LiveController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        return $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();
    }

    // GET /live/status
    public function status(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $guests  = $wedding->guests;
        $today   = now()->startOfDay();

        $daysUntil = $wedding->wedding_date
            ? (int) $today->diffInDays($wedding->wedding_date, false)
            : null;

        // Timeline events for the wedding day (or today if live)
        $dayEvents = $wedding->timelineEvents()
            ->whereDate('event_date', $wedding->wedding_date ?? $today)
            ->orderBy('event_date')
            ->orderBy('sort_order')
            ->get()
            ->map(fn ($e) => [
                'id'          => $e->id,
                'title'       => $e->title,
                'time'        => $e->start_time,
                'category'    => null,
                'location'    => $e->location,
                'description' => $e->description,
                'event_date'  => $e->event_date?->toDateString(),
            ]);

        // Upcoming events in the next 7 days (pre-wedding)
        $upcomingEvents = $wedding->timelineEvents()
            ->whereBetween('event_date', [$today, $today->copy()->addDays(7)])
            ->orderBy('event_date')
            ->limit(5)
            ->get()
            ->map(fn ($e) => [
                'id'          => $e->id,
                'title'       => $e->title,
                'time'        => $e->start_time,
                'category'    => null,
                'location'    => $e->location,
                'event_date'  => $e->event_date?->toDateString(),
            ]);

        return response()->json([
            'wedding_id'        => $wedding->id,
            'is_live'           => $wedding->status === 'live',
            'wedding_date'      => $wedding->wedding_date?->toDateString(),
            'days_until'        => $daysUntil,
            'partner_one_name'  => $wedding->partner_one_name,
            'partner_two_name'  => $wedding->partner_two_name,
            'venue_name'        => $wedding->venue_name,
            'total_guests'      => $guests->count(),
            'checked_in_count'  => $guests->whereNotNull('checked_in_at')->count(),
            'attending_count'   => $guests->where('rsvp_status', 'attending')->count(),
            'day_events'        => $dayEvents,
            'upcoming_events'   => $upcomingEvents,
        ]);
    }

    // GET /live/activity — unified real-time activity feed
    public function activity(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $checkIns = $wedding->guests()
            ->whereNotNull('checked_in_at')
            ->orderByDesc('checked_in_at')
            ->limit(20)
            ->get(['first_name', 'last_name', 'checked_in_at'])
            ->map(fn ($g) => [
                'type'        => 'check_in',
                'actor_name'  => trim("{$g->first_name} {$g->last_name}"),
                'description' => 'arrived and checked in',
                'occurred_at' => $g->checked_in_at->toIso8601String(),
            ]);

        $rsvps = $wedding->guests()
            ->whereNotNull('rsvp_responded_at')
            ->orderByDesc('rsvp_responded_at')
            ->limit(20)
            ->get(['first_name', 'last_name', 'rsvp_status', 'rsvp_responded_at'])
            ->map(fn ($g) => [
                'type'        => 'rsvp',
                'actor_name'  => trim("{$g->first_name} {$g->last_name}"),
                'description' => match ($g->rsvp_status) {
                    'attending' => 'is attending 🎉',
                    'declined'  => "can't make it 😢",
                    'maybe'     => 'is still deciding',
                    default     => 'responded',
                },
                'occurred_at' => $g->rsvp_responded_at->toIso8601String(),
            ]);

        $announcements = $wedding->guestMessages()
            ->where('channel', 'in_app')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get(['body', 'created_at'])
            ->map(fn ($m) => [
                'type'        => 'announcement',
                'actor_name'  => 'You',
                'description' => $m->body,
                'occurred_at' => $m->created_at->toIso8601String(),
            ]);

        $feed = collect()
            ->merge($checkIns)
            ->merge($rsvps)
            ->merge($announcements)
            ->sortByDesc('occurred_at')
            ->values()
            ->take(30);

        return response()->json(['activities' => $feed]);
    }

    // POST /live/activate
    public function activate(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $wedding->update(['status' => 'live']);
        return response()->json(['status' => 'live']);
    }

    // POST /live/deactivate
    public function deactivate(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $wedding->update(['status' => 'planning']);
        return response()->json(['status' => 'planning']);
    }
}
