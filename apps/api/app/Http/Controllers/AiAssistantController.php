<?php

namespace App\Http\Controllers;

use App\Models\AiAssistantLog;
use App\Models\Wedding;
use App\Services\OpenAiService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class AiAssistantController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $logs = $wedding->aiAssistantLogs()
            ->whereNotNull('response')
            ->orderByDesc('created_at')
            ->limit(20)
            ->get(['id', 'prompt', 'response', 'created_at'])
            ->reverse()
            ->values();

        return response()->json([
            'data' => $logs,
            'usage' => $this->usagePayload($wedding),
        ]);
    }

    public function health(Request $request): JsonResponse
    {
        $this->wedding($request);

        return response()->json([
            'data' => app(OpenAiService::class)->diagnostics(),
        ]);
    }

    public function chat(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'message' => 'required|string|max:2000',
        ]);

        app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'ai_assistant_calls_per_month');

        $history = $wedding->aiAssistantLogs()
            ->whereNotNull('response')
            ->orderByDesc('created_at')
            ->limit(6)
            ->get(['prompt', 'response'])
            ->reverse()
            ->flatMap(fn (AiAssistantLog $log) => [
                ['role' => 'user', 'content' => $log->prompt],
                ['role' => 'assistant', 'content' => $log->response],
            ])
            ->values()
            ->all();

        try {
            $reply = app(OpenAiService::class)->chat(
                $this->buildSystemPrompt($wedding),
                $history,
                $data['message'],
            );
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 502);
        }

        $log = $wedding->aiAssistantLogs()->create([
            'user_id' => $request->user()->id,
            'prompt' => $data['message'],
            'response' => $reply,
        ]);

        return response()->json([
            'data' => $log->only(['id', 'prompt', 'response', 'created_at']),
            'usage' => $this->usagePayload($wedding),
        ]);
    }

    private function usagePayload(Wedding $wedding): array
    {
        $payload = app(SubscriptionEntitlementService::class)->payloadFor($wedding);

        return [
            'used' => $payload['usage']['ai_assistant_calls_per_month'] ?? 0,
            'limit' => $payload['limits']['ai_assistant_calls_per_month'] ?? null,
        ];
    }

    private function buildSystemPrompt(Wedding $wedding): string
    {
        $guests = $wedding->guests();
        $totalGuests = $guests->count();
        $confirmed = (clone $guests)->where('attending_status', 'yes')->count();
        $pending = (clone $guests)->where(function ($q) {
            $q->whereNull('attending_status')->orWhere('attending_status', 'pending');
        })->count();
        $declined = (clone $guests)->where('attending_status', 'no')->count();
        $notInvited = (clone $guests)->where(function ($q) {
            $q->whereNull('invite_status')->orWhereNotIn('invite_status', ['sent', 'opened', 'accepted']);
        })->count();
        $missingMeals = (clone $guests)->where('attending_status', 'yes')->where(function ($q) {
            $q->whereNull('meal_preference')->orWhere('meal_preference', '');
        })->count();
        $dietaryFlags = (clone $guests)->where(function ($q) {
            $q->whereNotNull('allergies')->orWhereNotNull('dietary_note')->orWhereNotNull('dietary_tags');
        })->count();
        $travelingGuests = (clone $guests)->where('travel_required', true)->count();
        $missingAccommodation = (clone $guests)
            ->where('attending_status', 'yes')
            ->where('travel_required', true)
            ->whereNull('hotel_assignment_id')
            ->count();
        $missingTransport = (clone $guests)
            ->where('attending_status', 'yes')
            ->where('travel_required', true)
            ->whereNull('transport_assignment_id')
            ->count();

        $totalBudget = (float) ($wedding->settings['total_budget'] ?? 0);
        $estimatedSpend = (float) $wedding->budgetItems()->sum('estimated_amount');
        $actualSpend = (float) $wedding->budgetItems()->sum('actual_amount');
        $paid = (float) $wedding->budgetItems()->sum('paid_amount');
        $budgetRemaining = max($totalBudget - max($actualSpend, $estimatedSpend), 0);
        $openPayments = $wedding->budgetItems()
            ->where(function ($q) {
                $q->whereNull('payment_status')->orWhereNotIn('payment_status', ['paid', 'complete']);
            })
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(4)
            ->get(['name', 'category', 'due_date'])
            ->map(fn ($item) => trim(($item->name ?: $item->category ?: 'Payment') . ' due ' . $this->dateText($item->due_date)))
            ->values()
            ->all();

        $pendingTasks = $wedding->tasks()->where('completed', false)->count();
        $overdueTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->where('due_date', '<', now())
            ->count();
        $upcomingTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(6)
            ->get(['title', 'category', 'due_date', 'priority'])
            ->map(fn ($task) => trim(($task->title ?: 'Task') . ' (' . ($task->priority ?: 'medium') . ', due ' . $this->dateText($task->due_date) . ')'))
            ->values()
            ->all();

        $daysUntil = $wedding->event_date ? now()->diffInDays($wedding->event_date, false) : null;
        $nextEvents = $wedding->timelineItems()
            ->where('event_date', '>=', now()->toDateString())
            ->orderBy('event_date')->orderBy('start_time')
            ->limit(5)
            ->get(['title', 'event_date', 'start_time', 'location'])
            ->map(fn ($event) => trim(($event->title ?: 'Timeline item') . ' on ' . $this->dateText($event->event_date) . ($event->start_time ? ' at ' . $event->start_time : '') . ($event->location ? ' at ' . $event->location : '')))
            ->values()
            ->all();

        $tableCount = $wedding->seatingTables()->count();
        $unassignedAttending = (clone $guests)
            ->where('attending_status', 'yes')
            ->whereNull('seating_assignment_id')
            ->count();

        $coupleNames = trim(implode(' & ', array_filter([$wedding->couple_name_primary, $wedding->couple_name_secondary])));
        $vendorsTotal = $wedding->vendors()->count();
        $bookedVendors = $wedding->vendors()->whereIn('booking_status', ['booked', 'confirmed'])->count();
        $vendorBalances = $wedding->vendors()
            ->where('balance_due', '>', 0)
            ->orderBy('balance_due_date')
            ->limit(4)
            ->get(['name', 'category', 'balance_due', 'balance_due_date'])
            ->map(fn ($vendor) => trim(($vendor->name ?: $vendor->category ?: 'Vendor') . ' balance ' . $this->money((float) $vendor->balance_due) . ($vendor->balance_due_date ? ' due ' . $this->dateText($vendor->balance_due_date) : '')))
            ->values()
            ->all();
        $responsibilities = $wedding->weddingPartyResponsibilities()
            ->whereNotIn('status', ['done', 'completed'])
            ->orderBy('due_date')
            ->limit(5)
            ->get(['title', 'priority', 'due_date'])
            ->map(fn ($task) => trim(($task->title ?: 'Responsibility') . ' (' . ($task->priority ?: 'medium') . ($task->due_date ? ', due ' . $this->dateText($task->due_date) : '') . ')'))
            ->values()
            ->all();
        $weekendEvents = $wedding->weddingWeekendEvents()
            ->where('event_date', '>=', now()->toDateString())
            ->orderBy('event_date')->orderBy('start_time')
            ->limit(4)
            ->get(['title', 'event_date', 'start_time', 'location'])
            ->map(fn ($event) => trim(($event->title ?: 'Wedding weekend event') . ' on ' . $this->dateText($event->event_date) . ($event->start_time ? ' at ' . $event->start_time : '') . ($event->location ? ' at ' . $event->location : '')))
            ->values()
            ->all();
        $honeymoon = $wedding->honeymoonTrip()->first(['destination', 'departure_date', 'return_date', 'total_budget', 'status']);
        $venue = trim(implode(', ', array_filter([$wedding->primary_venue_name, $wedding->primary_venue_address, $wedding->city, $wedding->country])));

        $lines = [
            'You are Udo AI, the intelligent assistant inside the Udo wedding app.',
            'Act as a real wedding planner, day-of operations coordinator, guest logistics helper, honeymoon planner, vacation adviser, and travel expert.',
            'Ground every answer in the saved wedding context below. If exact data is missing, say what is missing and give the next best planning step instead of inventing facts.',
            'Prefer practical checklists, timelines, suggested messages, travel logistics, vendor follow-ups, and risk warnings. Keep answers warm, specific, concise, and action-oriented.',
            'For legal, medical, immigration, weather, venue, airline, or safety matters, give planning guidance and tell the user to verify with the official provider or relevant authority.',
            '',
            'Current date: ' . now()->toDateString() . '. Wedding timezone: ' . ($wedding->timezone ?: config('app.timezone')) . '.',
            'Wedding: ' . ($coupleNames !== '' ? $coupleNames : ($wedding->title ?: 'Unnamed wedding')),
            $daysUntil !== null ? 'Wedding date: ' . $this->dateText($wedding->event_date) . " ({$daysUntil} day(s) away)." : 'Wedding date not set yet.',
            'Venue/location: ' . ($venue !== '' ? $venue : 'not set'),
            $wedding->rsvp_deadline ? 'RSVP deadline: ' . $this->dateText($wedding->rsvp_deadline) . '.' : 'RSVP deadline not set.',
            "Guests: {$totalGuests} total; {$confirmed} confirmed, {$pending} pending, {$declined} declined, {$notInvited} not fully invited.",
            "Guest logistics: {$missingMeals} confirmed guest(s) missing meals, {$dietaryFlags} dietary/allergy flag(s), {$travelingGuests} traveling guest(s), {$missingAccommodation} missing accommodation, {$missingTransport} missing transport.",
            'Budget: total ' . $this->money($totalBudget) . ', estimated ' . $this->money($estimatedSpend) . ', actual ' . $this->money($actualSpend) . ', paid ' . $this->money($paid) . ', remaining ' . $this->money($budgetRemaining) . '.',
            'Open payments: ' . $this->compactList($openPayments),
            "Vendors: {$vendorsTotal} total, {$bookedVendors} booked/confirmed. Balances: " . $this->compactList($vendorBalances),
            "Tasks: {$pendingTasks} pending, {$overdueTasks} overdue. Upcoming: " . $this->compactList($upcomingTasks),
            'Wedding party responsibilities: ' . $this->compactList($responsibilities),
            'Timeline: ' . $this->compactList($nextEvents),
            'Wedding weekend: ' . $this->compactList($weekendEvents),
            "Seating: {$tableCount} table(s) set up, {$unassignedAttending} confirmed guest(s) not yet seated.",
            $honeymoon
                ? 'Honeymoon/travel: destination ' . ($honeymoon->destination ?: 'not set') . ', depart ' . $this->dateText($honeymoon->departure_date) . ', return ' . $this->dateText($honeymoon->return_date) . ', budget ' . $this->money((float) $honeymoon->total_budget) . ', status ' . ($honeymoon->status ?: 'not set') . '.'
                : 'Honeymoon/travel: no honeymoon trip saved yet.',
        ];

        return implode("\n", $lines);
    }

    private function money(float $amount): string
    {
        return '$' . number_format($amount, 2);
    }

    private function dateText($date): string
    {
        if (! $date) {
            return 'not set';
        }

        return method_exists($date, 'toDateString') ? $date->toDateString() : (string) $date;
    }

    private function compactList(array $items): string
    {
        return empty($items) ? 'none saved' : implode('; ', $items);
    }
}
