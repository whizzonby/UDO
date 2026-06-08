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

        $todaysFocus  = $this->buildTodaysFocus($wedding, $tasks, $guests, $vendors);
        $guidancePrompts = $this->buildGuidancePrompts($wedding);
        $priorities   = $this->buildPriorities($wedding, $vendors, $guests, $budgetItems);

        return response()->json([
            'wedding' => [
                'id'               => $wedding->id,
                'partner_one_name' => $wedding->partner_one_name,
                'partner_two_name' => $wedding->partner_two_name,
                'wedding_date'     => $wedding->wedding_date?->toDateString(),
                'venue_name'       => $wedding->venue_name,
                'venue_city'       => $wedding->venue_city,
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
            'alerts'          => $alerts,
            'todays_focus'    => $todaysFocus,
            'guidance_prompts' => $guidancePrompts,
            'priorities'      => $priorities,
        ]);
    }

    private function buildTodaysFocus(Wedding $wedding, $tasks, $guests, $vendors): array
    {
        $items = [];

        // Overdue tasks
        $overdue = $tasks->filter(fn ($t) =>
            $t->due_date && $t->due_date->isPast() && $t->status !== 'complete'
        )->take(1)->first();
        if ($overdue) {
            $items[] = [
                'id'           => 'overdue_' . $overdue->id,
                'title'        => 'Review overdue task: ' . $overdue->title,
                'reason'       => 'This is past its due date and may affect other plans.',
                'action_label' => 'Go to tasks',
                'action_route' => '/plan/tasks',
                'is_done'      => false,
            ];
        }

        // Guests without RSVP
        $unresponsive = $guests->where('rsvp_status', 'pending')->count();
        if ($unresponsive > 0) {
            $items[] = [
                'id'           => 'rsvp_followup',
                'title'        => "Follow up with {$unresponsive} guests",
                'reason'       => 'Still awaiting their RSVP response.',
                'action_label' => 'Send reminder',
                'action_route' => '/guests/invitations',
                'is_done'      => false,
            ];
        }

        // Unpaid vendor deposits
        $depositDue = $vendors->filter(fn ($v) =>
            $v->deposit_due_date &&
            $v->deposit_paid_at === null &&
            $v->deposit_due_date->between(now(), now()->addDays(14))
        )->take(1)->first();
        if ($depositDue) {
            $items[] = [
                'id'           => 'deposit_' . $depositDue->id,
                'title'        => "Pay deposit: {$depositDue->name}",
                'reason'       => "Due " . $depositDue->deposit_due_date->diffForHumans() . '.',
                'action_label' => 'Review vendor',
                'action_route' => '/plan/vendors',
                'is_done'      => false,
            ];
        }

        return array_slice($items, 0, 3);
    }

    private function buildGuidancePrompts(Wedding $wedding): array
    {
        $allPrompts = [
            ['id' => 'g1', 'question' => 'What does your dream morning-of feel like?', 'context' => 'Setting the tone for the day before it begins.', 'category' => 'Mindset'],
            ['id' => 'g2', 'question' => 'Have you talked to your vendors about your vision recently?', 'context' => 'A quick check-in can prevent day-of surprises.', 'category' => 'Vendors'],
            ['id' => 'g3', 'question' => 'Which guests might need extra care or consideration?', 'context' => 'Guests who travel far or have accessibility needs.', 'category' => 'Guests'],
            ['id' => 'g4', 'question' => 'Is there a moment you want to protect from the schedule?', 'context' => 'A quiet first look, a family photo, a shared breath.', 'category' => 'Moments'],
            ['id' => 'g5', 'question' => 'What would make you feel most prepared right now?', 'context' => 'Focus on the one thing that would bring the most calm.', 'category' => 'Mindset'],
        ];

        // Rotate prompts based on day of year for variety
        $offset = now()->dayOfYear % count($allPrompts);
        return array_values(array_slice(
            array_merge(array_slice($allPrompts, $offset), array_slice($allPrompts, 0, $offset)),
            0, 5
        ));
    }

    private function buildPriorities(Wedding $wedding, $vendors, $guests, $budgetItems): array
    {
        $priorities = [];

        // Over-budget categories
        foreach ($budgetItems->groupBy('category') as $cat => $items) {
            $budgeted = (float) $items->sum('budgeted_amount');
            $spent    = (float) $items->sum('actual_amount');
            if ($budgeted > 0 && $spent > $budgeted * 0.95) {
                $priorities[] = [
                    'id'           => 'budget_cat_' . str($cat)->slug(),
                    'title'        => "{$cat} is near budget limit",
                    'body'         => 'You\'ve used ' . round($spent / $budgeted * 100) . '% of this category budget.',
                    'level'        => $spent > $budgeted ? 'urgent' : 'warning',
                    'action_label' => 'Review budget',
                    'action_route' => '/plan/budget',
                    'amount'       => '$' . number_format($spent, 0),
                ];
            }
        }

        return array_slice($priorities, 0, 3);
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
