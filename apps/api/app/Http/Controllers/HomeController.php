<?php

namespace App\Http\Controllers;

use App\Services\SmartAlertService;
use App\Services\OperationalHealthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class HomeController extends Controller
{
    public function index(Request $request, SmartAlertService $smartAlerts, OperationalHealthService $health): JsonResponse
    {
        $user    = $request->user();
        $wedding = $user->activeWedding;

        if (! $wedding) {
            return response()->json(['wedding' => null, 'stats' => [], 'upcoming_tasks' => []]);
        }

        $guestCount     = $wedding->guests()->count();
        $confirmedCount = $wedding->guests()->where('attending_status', 'yes')->count();
        $declinedCount  = $wedding->guests()->where('attending_status', 'no')->count();
        $pendingGuestCount = $guestCount - $confirmedCount - $declinedCount;

        $totalTasks     = $wedding->tasks()->count();
        $completedTasks = $wedding->tasks()->where('completed', true)->count();
        $pendingTasks   = $totalTasks - $completedTasks;
        $overdueTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereDate('due_date', '<', now()->toDateString())
            ->count();

        $upcomingTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get(['id', 'title', 'due_date', 'priority']);

        $budgetItems   = $wedding->budgetItems();
        $budgetSpent   = $budgetItems->sum('actual_amount');
        $budgetTotal   = $wedding->settings['total_budget'] ?? $budgetItems->sum('estimated_amount');
        $budgetDueSoon = $wedding->budgetItems()
            ->where('payment_status', '!=', 'paid')
            ->whereNotNull('due_date')
            ->whereDate('due_date', '<=', now()->addDays(14)->toDateString())
            ->orderBy('due_date')
            ->limit(5)
            ->get(['id', 'name', 'category', 'due_date', 'payment_status', 'actual_amount', 'paid_amount']);
        $unpaidBalance = max(0, (float) $wedding->budgetItems()->sum('actual_amount') - (float) $wedding->budgetItems()->sum('paid_amount'));

        $daysUntil = $wedding->event_date
            ? (int) now()->startOfDay()->diffInDays($wedding->event_date, false)
            : null;
        $rsvpCompletion = $guestCount > 0 ? round((($confirmedCount + $declinedCount) / $guestCount) * 100) : 0;
        $taskCompletion = $totalTasks > 0 ? round(($completedTasks / $totalTasks) * 100) : 0;
        $budgetUsage = (float) $budgetTotal > 0 ? round(((float) $budgetSpent / (float) $budgetTotal) * 100) : 0;

        $travellingGuests = $wedding->guests()->where('travel_required', true)->get();
        $guestIssues = [
            'pending_rsvps' => $pendingGuestCount,
            'missing_meals' => $wedding->guests()
                ->where('attending_status', 'yes')
                ->whereNull('meal_preference')
                ->count(),
            'missing_arrival_info' => $travellingGuests
                ->filter(fn ($guest) => ! $guest->arrival_date || ! $guest->arrival_time)
                ->count(),
            'missing_accommodation' => $travellingGuests
                ->filter(fn ($guest) => ! $guest->hotel_assignment_id)
                ->count(),
            'missing_transport' => $travellingGuests
                ->filter(fn ($guest) => ! $guest->transport_assignment_id)
                ->count(),
            'unassigned_seating' => $wedding->guests()
                ->where('attending_status', 'yes')
                ->whereNull('seating_assignment_id')
                ->count(),
            'vip_needs_attention' => $wedding->guests()
                ->where('vip_flag', true)
                ->where('attending_status', '!=', 'no')
                ->where(function ($query) {
                    $query
                        ->whereNull('seating_assignment_id')
                        ->orWhere(function ($travelQuery) {
                            $travelQuery
                                ->where('travel_required', true)
                                ->where(function ($missingQuery) {
                                    $missingQuery
                                        ->whereNull('arrival_date')
                                        ->orWhereNull('hotel_assignment_id')
                                        ->orWhereNull('transport_assignment_id');
                                });
                        });
                })
                ->count(),
        ];
        $openLiveIssues = $wedding->liveUpdates()
            ->whereIn('type', ['incident', 'alert'])
            ->where('status', '!=', 'resolved')
            ->count();
        $timelineCount = $wedding->timelineItems()->count();
        $vendorReadiness = [
            'confirmed' => $wedding->vendors()->where('booking_status', 'confirmed')->count(),
            'total' => $wedding->vendors()->count(),
            'missing_contracts' => $wedding->vendors()->where('booking_status', 'confirmed')->where('contract_signed', false)->count(),
        ];
        $planningScore = $this->averageScore([
            $taskCompletion,
            $rsvpCompletion,
            $timelineCount > 0 ? 100 : 0,
            $vendorReadiness['total'] > 0 ? round(($vendorReadiness['confirmed'] / $vendorReadiness['total']) * 100) : 0,
            $guestIssues['unassigned_seating'] === 0 && $confirmedCount > 0 ? 100 : 40,
        ]);
        $liveReadinessScore = $this->averageScore([
            $timelineCount > 0 ? 100 : 0,
            $openLiveIssues === 0 ? 100 : 25,
            $guestIssues['missing_arrival_info'] === 0 ? 100 : 50,
            $vendorReadiness['missing_contracts'] === 0 ? 100 : 60,
            $guestIssues['vip_needs_attention'] === 0 ? 100 : 45,
        ]);
        $actions = $this->priorityActions($guestIssues, $overdueTasks, $budgetUsage, $openLiveIssues, $timelineCount, $upcomingTasks);
        $smartAlertSummary = $smartAlerts->summary($wedding);
        $platformHealth = $health->snapshot($wedding);

        return response()->json([
            'wedding' => [
                'id'           => $wedding->id,
                'slug'         => $wedding->slug,
                'couple_names' => $wedding->couple_name_secondary
                    ? "{$wedding->couple_name_primary} & {$wedding->couple_name_secondary}"
                    : $wedding->couple_name_primary,
                'event_date'   => $wedding->event_date?->toDateString(),
                'venue_name'   => $wedding->primary_venue_name,
                'venue_city'   => $wedding->city,
                'days_until'   => $daysUntil,
                'status'       => $wedding->status,
            ],
            'stats' => [
                'total_guests'     => $guestCount,
                'confirmed_guests' => $confirmedCount,
                'declined_guests'  => $declinedCount,
                'pending_guests'   => $pendingGuestCount,
                'total_tasks'      => $totalTasks,
                'completed_tasks'  => $completedTasks,
                'pending_tasks'    => $pendingTasks,
                'overdue_tasks'    => $overdueTasks,
                'budget_spent'     => (float) $budgetSpent,
                'budget_total'     => (float) $budgetTotal,
            ],
            'command_center' => [
                'planning_health' => [
                    'score' => $planningScore,
                    'label' => $this->scoreLabel($planningScore),
                    'task_completion' => $taskCompletion,
                    'days_until' => $daysUntil,
                ],
                'rsvp_health' => [
                    'completion' => $rsvpCompletion,
                    'pending' => $pendingGuestCount,
                    'confirmed' => $confirmedCount,
                    'declined' => $declinedCount,
                    'deadline' => $wedding->rsvp_deadline?->toDateString(),
                ],
                'budget_status' => [
                    'usage' => $budgetUsage,
                    'spent' => (float) $budgetSpent,
                    'total' => (float) $budgetTotal,
                    'remaining' => max(0, (float) $budgetTotal - (float) $budgetSpent),
                    'unpaid_balance' => $unpaidBalance,
                    'due_soon' => $budgetDueSoon,
                ],
                'guest_issues' => $guestIssues,
                'live_readiness' => [
                    'score' => $liveReadinessScore,
                    'label' => $this->scoreLabel($liveReadinessScore),
                    'open_incidents' => $openLiveIssues,
                    'timeline_items' => $timelineCount,
                    'vendor_readiness' => $vendorReadiness,
                ],
                'upcoming_actions' => $actions,
                'smart_alerts' => $smartAlertSummary,
                'platform_health' => $platformHealth,
            ],
            'upcoming_tasks' => $upcomingTasks,
        ]);
    }

    private function averageScore(array $scores): int
    {
        $scores = array_filter($scores, fn ($score) => is_numeric($score));
        if (empty($scores)) {
            return 0;
        }
        return (int) round(array_sum($scores) / count($scores));
    }

    private function scoreLabel(int $score): string
    {
        if ($score >= 85) {
            return 'Strong';
        }
        if ($score >= 65) {
            return 'On track';
        }
        if ($score >= 40) {
            return 'Needs attention';
        }
        return 'At risk';
    }

    private function priorityActions(array $guestIssues, int $overdueTasks, float|int $budgetUsage, int $openLiveIssues, int $timelineCount, Collection $upcomingTasks): array
    {
        $actions = [];
        if ($openLiveIssues > 0) {
            $actions[] = ['id' => 'live-incidents', 'title' => 'Resolve open live issues', 'reason' => "{$openLiveIssues} issue(s) need a decision", 'priority' => 'critical', 'target' => 'live'];
        }
        if ($overdueTasks > 0) {
            $actions[] = ['id' => 'overdue-tasks', 'title' => 'Clear overdue planning tasks', 'reason' => "{$overdueTasks} task(s) are overdue", 'priority' => 'high', 'target' => 'plan'];
        }
        if ($guestIssues['pending_rsvps'] > 0) {
            $actions[] = ['id' => 'pending-rsvps', 'title' => 'Send RSVP reminders', 'reason' => "{$guestIssues['pending_rsvps']} guests have not answered", 'priority' => 'high', 'target' => 'guests'];
        }
        if ($guestIssues['vip_needs_attention'] > 0) {
            $actions[] = ['id' => 'vip-attention', 'title' => 'Review VIP guest readiness', 'reason' => "{$guestIssues['vip_needs_attention']} VIP guest(s) need logistics or seating", 'priority' => 'high', 'target' => 'guests'];
        }
        if ($budgetUsage >= 90) {
            $actions[] = ['id' => 'budget-risk', 'title' => 'Review budget pressure', 'reason' => "{$budgetUsage}% of budget is allocated or spent", 'priority' => 'medium', 'target' => 'plan'];
        }
        if ($timelineCount === 0) {
            $actions[] = ['id' => 'timeline-empty', 'title' => 'Build the wedding-day timeline', 'reason' => 'Live mode needs a timeline to guide the day', 'priority' => 'medium', 'target' => 'plan'];
        }

        foreach ($upcomingTasks->take(3) as $task) {
            $actions[] = [
                'id' => "task-{$task->id}",
                'title' => $task->title,
                'reason' => $task->due_date ? 'Due ' . $task->due_date->toDateString() : 'Planning task',
                'priority' => $task->priority,
                'target' => 'plan',
            ];
        }

        return array_slice($actions, 0, 6);
    }
}
