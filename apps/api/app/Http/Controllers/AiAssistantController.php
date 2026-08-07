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
            ->orderBy('created_at')
            ->limit(20)
            ->get(['id', 'prompt', 'response', 'created_at']);

        return response()->json([
            'data' => $logs,
            'usage' => $this->usagePayload($wedding),
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

    /**
     * A compact summary of this wedding's real numbers — guests, budget,
     * tasks, timeline, seating — so the assistant's answers are grounded in
     * what's actually saved rather than generic advice. Deliberately just a
     * few counts, not a full data dump: keeps the prompt small and cheap.
     */
    private function buildSystemPrompt(Wedding $wedding): string
    {
        $guests = $wedding->guests();
        $totalGuests = $guests->count();
        $confirmed = (clone $guests)->where('attending_status', 'yes')->count();
        $pending = (clone $guests)->where(function ($q) {
            $q->whereNull('attending_status')->orWhere('attending_status', 'pending');
        })->count();
        $declined = (clone $guests)->where('attending_status', 'no')->count();

        $totalBudget = (float) ($wedding->settings['total_budget'] ?? 0);
        $estimatedSpend = (float) $wedding->budgetItems()->sum('estimated_amount');
        $actualSpend = (float) $wedding->budgetItems()->sum('actual_amount');
        $paid = (float) $wedding->budgetItems()->sum('paid_amount');

        $pendingTasks = $wedding->tasks()->where('completed', false)->count();
        $overdueTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->where('due_date', '<', now())
            ->count();

        $daysUntil = $wedding->event_date ? now()->diffInDays($wedding->event_date, false) : null;
        $nextEvent = $wedding->timelineItems()
            ->where('event_date', '>=', now()->toDateString())
            ->orderBy('event_date')->orderBy('start_time')
            ->first();

        $tableCount = $wedding->seatingTables()->count();
        $unassignedAttending = (clone $guests)
            ->where('attending_status', 'yes')
            ->whereNull('seating_assignment_id')
            ->count();

        $coupleNames = trim(implode(' & ', array_filter([$wedding->couple_name_primary, $wedding->couple_name_secondary])));

        $lines = [
            "You are Udo's AI Wedding Assistant, a warm and practical planning helper inside the Udo wedding app.",
            'Answer using the real numbers below whenever the question is about this wedding. Be concise, specific, and actionable. Never invent numbers not given here — say so and suggest where in the app to check instead.',
            '',
            'Wedding: ' . ($coupleNames !== '' ? $coupleNames : ($wedding->title ?: 'Unnamed wedding')),
            $daysUntil !== null ? "Days until the wedding: {$daysUntil}" : 'Wedding date not set yet.',
            "Guests: {$totalGuests} total — {$confirmed} confirmed, {$pending} pending, {$declined} declined.",
            "Budget: total budget \${$totalBudget}, estimated spend \${$estimatedSpend}, actual spend \${$actualSpend}, paid so far \${$paid}.",
            "Tasks: {$pendingTasks} pending, {$overdueTasks} overdue.",
            "Seating: {$tableCount} table(s) set up, {$unassignedAttending} confirmed guest(s) not yet seated.",
            $nextEvent
                ? 'Next timeline event: ' . ($nextEvent->title ?? 'Untitled') . ' on ' . $nextEvent->event_date
                : 'No upcoming timeline events scheduled.',
        ];

        return implode("\n", $lines);
    }
}
