<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $user    = $request->user();
        $wedding = $user->weddings()->latest('wedding_users.created_at')->firstOrFail();

        $wedding->load(['tasks', 'budgetItems', 'vendors', 'timelineEvents', 'guests']);

        $tasks       = $wedding->tasks;
        $budgetItems = $wedding->budgetItems;
        $guests      = $wedding->guests;
        $vendors     = $wedding->vendors;
        $events      = $wedding->timelineEvents;

        // Task stats
        $totalTasks    = $tasks->count();
        $doneTasks     = $tasks->where('status', 'complete')->count();
        $pendingTasks  = $tasks->whereIn('status', ['pending', 'in_progress'])->count();

        // Budget stats
        $totalBudgeted = (float) $budgetItems->sum('budgeted_amount');
        $totalActual   = (float) $budgetItems->sum(fn ($i) => $i->actual_amount ?? $i->budgeted_amount);
        $topCategory   = $budgetItems->groupBy('category')
            ->map(fn ($g) => $g->sum('budgeted_amount'))
            ->sortDesc()->keys()->first();
        $pendingDeposits = $vendors->whereIn('status', ['booked', 'confirmed'])
            ->whereNotNull('deposit_due_date')
            ->where('deposit_paid_at', null)->count();
        $pendingDepositsAmount = $vendors->whereIn('status', ['booked', 'confirmed'])
            ->whereNotNull('deposit_due_date')
            ->where('deposit_paid_at', null)->sum('deposit_amount');

        // Guest stats
        $invited   = $guests->count();
        $attending = $guests->where('rsvp_status', 'attending')->count();
        $declined  = $guests->where('rsvp_status', 'declined')->count();
        $pending   = $guests->where('rsvp_status', 'pending')->count();

        // Smart alerts
        $alerts = $this->buildAlerts($wedding, $vendors, $guests);

        // Upcoming timeline events (next 3)
        $upcoming = $events->filter(fn ($e) => $e->event_date >= now()->toDateString())
            ->take(3)->values();

        return response()->json([
            'wedding' => [
                'id'               => $wedding->id,
                'partner_one_name' => $wedding->partner_one_name,
                'partner_two_name' => $wedding->partner_two_name,
                'wedding_date'     => $wedding->wedding_date?->toDateString(),
                'status'           => $wedding->status,
            ],
            'plan' => [
                'total_tasks'     => $totalTasks,
                'done_tasks'      => $doneTasks,
                'pending_tasks'   => $pendingTasks,
                'completion_pct'  => $totalTasks > 0 ? round($doneTasks / $totalTasks * 100) : 0,
                'overdue_tasks'   => $tasks->filter(fn ($t) => $t->due_date && $t->due_date->isPast() && $t->status !== 'complete')->count(),
            ],
            'budget' => [
                'total_budget'             => $wedding->total_budget,
                'total_budgeted'           => $totalBudgeted,
                'total_spent'              => $totalActual,
                'remaining'                => max(0, ($wedding->total_budget ?? $totalBudgeted) - $totalActual),
                'spend_pct'                => $totalBudgeted > 0 ? round($totalActual / $totalBudgeted * 100) : 0,
                'top_spend_category'       => $topCategory,
                'pending_deposits_count'   => $pendingDeposits,
                'pending_deposits_amount'  => (float) $pendingDepositsAmount,
            ],
            'guests' => [
                'total_invited' => $invited,
                'attending'     => $attending,
                'declined'      => $declined,
                'pending'       => $pending,
            ],
            'upcoming_events' => $upcoming->map(fn ($e) => [
                'id'           => $e->id,
                'title'        => $e->title,
                'event_date'   => $e->event_date->toDateString(),
                'start_time'   => $e->start_time,
                'location'     => $e->location,
                'color'        => $e->color,
                'is_wedding_day' => $e->is_wedding_day,
            ])->values(),
            'alerts' => $alerts,
        ]);
    }

    private function buildAlerts(Wedding $wedding, $vendors, $guests): array
    {
        $alerts = [];

        // Vendor deposit due soon (within 7 days)
        $soon = $vendors->filter(fn ($v) =>
            $v->deposit_due_date &&
            $v->deposit_paid_at === null &&
            $v->deposit_due_date->between(now(), now()->addDays(7))
        );
        foreach ($soon as $v) {
            $alerts[] = [
                'type'    => 'vendor_deposit_due',
                'message' => "Vendor deposit due in {$v->deposit_due_date->diffInDays(now())} day(s)",
                'detail'  => "{$v->name} — \${$v->deposit_amount}",
                'level'   => 'warning',
            ];
        }

        // Guests pending RSVP (more than 5)
        $pendingGuests = $guests->where('rsvp_status', 'pending')->count();
        if ($pendingGuests > 5) {
            $alerts[] = [
                'type'    => 'rsvp_pending',
                'message' => "{$pendingGuests} guests haven't RSVP'd",
                'detail'  => null,
                'level'   => 'info',
            ];
        }

        return $alerts;
    }
}
