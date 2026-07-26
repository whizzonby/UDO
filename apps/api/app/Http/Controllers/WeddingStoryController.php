<?php

namespace App\Http\Controllers;

use App\Models\MemoryGuestbookEntry;
use App\Models\Wedding;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

/**
 * A read-only aggregation over data already owned by other modules
 * (Guests, Planning, Gallery, Wedding Party, Memories, Honeymoon) — bucketed
 * into 5 real phases by comparing real timestamps to the real wedding date.
 * Nothing here is generated or fabricated; every count is a real query.
 */
class WeddingStoryController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    public function show(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $isCoreCouple = app(WeddingAccessService::class)->isCoreCouple($request->user(), $wedding);
        $eventDate = $wedding->event_date ? Carbon::parse($wedding->event_date)->startOfDay() : null;

        $honeymoon = $wedding->honeymoonTrip;

        return response()->json([
            'data' => [
                'has_event_date' => $eventDate !== null,
                'phases' => [
                    $this->engagementPhase($wedding, $eventDate),
                    $this->weddingWeekPhase($wedding, $eventDate),
                    $this->weddingDayPhase($wedding, $eventDate),
                    $this->honeymoonPhase($honeymoon),
                    $this->happilyEverAfterPhase($wedding, $eventDate),
                ],
                'memories' => $this->memoriesSummary($wedding, $isCoreCouple),
            ],
        ]);
    }

    private function engagementPhase(Wedding $wedding, ?Carbon $eventDate): array
    {
        $weekStart = $eventDate?->copy()->subDays(7);
        $tasksCompleted = $wedding->tasks()->where('completed', true)
            ->when($weekStart, fn ($q) => $q->where('completed_at', '<', $weekStart))
            ->count();
        $vendorsBooked = $wedding->vendors()->where('booking_status', 'confirmed')->count();
        $invitationsSent = $wedding->messages()->where('message_type', 'invitation')->whereNotNull('sent_at')->count();
        $inspirationSaved = $wedding->galleryAssets()->where('album', 'inspiration')->count();

        return [
            'key' => 'engagement_planning',
            'title' => 'Engagement & Planning',
            'stats' => [
                'tasks_completed' => $tasksCompleted,
                'vendors_booked' => $vendorsBooked,
                'invitations_sent' => $invitationsSent,
                'inspiration_saved' => $inspirationSaved,
            ],
        ];
    }

    private function weddingWeekPhase(Wedding $wedding, ?Carbon $eventDate): array
    {
        $totalGuests = $wedding->guests()->count();
        $answered = $wedding->guests()->whereIn('attending_status', ['yes', 'no'])->count();
        $rsvpRate = $totalGuests > 0 ? round(($answered / $totalGuests) * 100, 1) : null;
        $seated = $wedding->guests()->where('attending_status', 'yes')->whereNotNull('seating_assignment_id')->count();
        $attending = $wedding->guests()->where('attending_status', 'yes')->count();

        return [
            'key' => 'wedding_week',
            'title' => 'Wedding Week',
            'stats' => [
                'rsvp_completion_rate' => $rsvpRate,
                'attending_guests' => $attending,
                'guests_seated' => $seated,
            ],
        ];
    }

    private function weddingDayPhase(Wedding $wedding, ?Carbon $eventDate): array
    {
        if (! $eventDate) {
            return ['key' => 'wedding_day', 'title' => 'Wedding Day', 'stats' => null];
        }

        $timelineItems = $wedding->timelineItems()
            ->whereDate('event_date', $eventDate->toDateString())
            ->get(['id', 'title', 'start_time', 'event_type'])
            ->values();

        $dayAssets = $wedding->galleryAssets()->whereDate('created_at', $eventDate->toDateString());

        $guestbookEntries = $wedding->memoryGuestbook
            ? MemoryGuestbookEntry::where('memory_guestbook_id', $wedding->memoryGuestbook->id)
                ->whereDate('created_at', $eventDate->toDateString())
                ->count()
            : 0;

        return [
            'key' => 'wedding_day',
            'title' => 'Wedding Day',
            'stats' => [
                'timeline_items' => $timelineItems,
                'photos' => (clone $dayAssets)->where('type', 'photo')->count(),
                'videos' => (clone $dayAssets)->where('type', 'video')->count(),
                'voice_notes' => (clone $dayAssets)->where('type', 'voice')->count(),
                'guestbook_messages' => $guestbookEntries,
            ],
        ];
    }

    private function honeymoonPhase($honeymoon): array
    {
        if (! $honeymoon) {
            return ['key' => 'honeymoon', 'title' => 'Honeymoon', 'stats' => null];
        }

        return [
            'key' => 'honeymoon',
            'title' => 'Honeymoon',
            'stats' => [
                'destination' => $honeymoon->destination,
                'departure_date' => optional($honeymoon->departure_date)->toDateString(),
                'return_date' => optional($honeymoon->return_date)->toDateString(),
                'status' => $honeymoon->status,
            ],
        ];
    }

    private function happilyEverAfterPhase(Wedding $wedding, ?Carbon $eventDate): array
    {
        if (! $eventDate || $eventDate->isFuture()) {
            return ['key' => 'happily_ever_after', 'title' => 'Happily Ever After', 'stats' => null];
        }

        $afterAssets = $wedding->galleryAssets()->where('created_at', '>', $eventDate->copy()->endOfDay());
        $guestbookAfter = $wedding->memoryGuestbook
            ? MemoryGuestbookEntry::where('memory_guestbook_id', $wedding->memoryGuestbook->id)
                ->where('created_at', '>', $eventDate->copy()->endOfDay())
                ->count()
            : 0;

        return [
            'key' => 'happily_ever_after',
            'title' => 'Happily Ever After',
            'stats' => [
                'photos_since' => (clone $afterAssets)->where('type', 'photo')->count(),
                'videos_since' => (clone $afterAssets)->where('type', 'video')->count(),
                'guestbook_messages_since' => $guestbookAfter,
                'days_married' => $eventDate->diffInDays(now()),
            ],
        ];
    }

    private function memoriesSummary(Wedding $wedding, bool $isCoreCouple): array
    {
        $speeches = $wedding->memorySpeeches()->where('confirmed', true)->get(['speaker_name', 'role']);
        $vows = $wedding->memoryVows()
            ->when(! $isCoreCouple, fn ($q) => $q->where('is_private', false))
            ->get(['id', 'title', 'is_private', 'viewed_at']);
        $traditions = $wedding->memoryTraditions()
            ->when(! $isCoreCouple, fn ($q) => $q->where('visibility', 'shared'))
            ->get(['name']);
        $music = $wedding->memoryMusicMoment;

        return [
            'speeches_confirmed' => $speeches->map(fn ($s) => ['speaker_name' => $s->speaker_name, 'role' => $s->role])->values(),
            'vows' => $vows->map(fn ($v) => ['id' => $v->id, 'title' => $v->title, 'is_private' => $v->is_private, 'viewed' => $v->viewed_at !== null])->values(),
            'traditions' => $traditions->pluck('name')->values(),
            'has_music_moments' => $music !== null,
        ];
    }
}
