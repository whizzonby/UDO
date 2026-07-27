<?php

namespace App\Http\Controllers;

use App\Services\SmartAlertService;
use App\Services\OperationalHealthService;
use App\Services\WeatherService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class HomeController extends Controller
{
    public function index(Request $request, SmartAlertService $smartAlerts, OperationalHealthService $health, WeatherService $weather): JsonResponse
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
            ->orderByRaw('CASE WHEN due_date IS NULL THEN 1 ELSE 0 END')
            ->orderBy('due_date')
            ->orderBy('priority')
            ->limit(6)
            ->get(['id', 'title', 'category', 'due_date', 'priority'])
            ->map(fn ($task) => [
                'id' => $task->id,
                'title' => $task->title,
                'display_title' => $this->momentTitle($task->title, $task->category),
                'category' => $task->category,
                'due_date' => $task->due_date,
                'priority' => $task->priority,
            ]);

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

        $weatherSnapshot = ($wedding->venue_lat !== null && $wedding->venue_lng !== null)
            ? $weather->forecast((float) $wedding->venue_lat, (float) $wedding->venue_lng, $wedding->event_date)
            : null;
        $recentActivity = $this->recentActivity($wedding, $weatherSnapshot);
        $settings = is_array($wedding->settings) ? $wedding->settings : [];
        $timelineItems = $wedding->event_date
            ? $wedding->timelineItems()
                ->whereDate('event_date', $wedding->event_date->toDateString())
                ->get(['title', 'event_type', 'start_time'])
            : collect();
        $ceremonyTime = optional($timelineItems->first(fn ($item) => str_contains(strtolower(($item->event_type ?? '') . ' ' . ($item->title ?? '')), 'ceremony')))->start_time;
        $receptionTime = optional($timelineItems->first(fn ($item) => str_contains(strtolower(($item->event_type ?? '') . ' ' . ($item->title ?? '')), 'reception')))->start_time;

        return response()->json([
            'wedding' => [
                'id'           => $wedding->id,
                'slug'         => $wedding->slug,
                'guest_portal_url' => rtrim((string) config('app.frontend_url', config('app.url')), '/') . '/w/' . $wedding->slug,
                'couple_names' => $wedding->couple_name_secondary
                    ? "{$wedding->couple_name_primary} & {$wedding->couple_name_secondary}"
                    : $wedding->couple_name_primary,
                'event_date'   => $wedding->event_date?->toDateString(),
                'venue_name'   => $wedding->primary_venue_name,
                'reception_venue_name' => $settings['reception_venue_name'] ?? null,
                'ceremony_time' => $ceremonyTime,
                'reception_time' => $receptionTime,
                'dress_code' => $settings['dress_code'] ?? null,
                'website_url' => $settings['website_url'] ?? null,
                'venue_city'   => $wedding->city,
                'venue_lat'    => $wedding->venue_lat,
                'venue_lng'    => $wedding->venue_lng,
                'destination'  => implode(', ', array_filter([$wedding->city, $wedding->country])) ?: null,
                'cover_photo_path' => $wedding->cover_photo_path,
                'couple_photo_path' => $wedding->couple_photo_path,
                'hashtag'      => $wedding->hashtag,
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
            'recent_activity' => $recentActivity,
            'weather' => $weatherSnapshot,
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

    private function momentTitle(?string $title, ?string $category = null): string
    {
        $raw = trim((string) $title);
        if ($raw === '') {
            return $category ? Str::title($category) : 'Wedding task';
        }

        $text = Str::of($raw)->lower()->squish()->toString();
        $patterns = [
            '/\b(taste|tasting|sample|sampled|try)\b.*\bcake\b/' => 'Cake tasting',
            '/\bcake\b.*\b(taste|tasting|sample|sampled|try)\b/' => 'Cake tasting',
            '/\b(menu|meal|food|catering)\b.*\b(taste|tasting|sample|sampling)\b/' => 'Menu tasting',
            '/\b(dress|suit|attire|gown|tux)\b.*\b(fit|fitting|try|trial)\b/' => 'Dress fitting',
            '/\b(venue|site|location)\b.*\b(walk|walkthrough|visit|tour)\b/' => 'Venue walkthrough',
            '/\b(florist|flowers|floral)\b.*\b(call|consult|consultation|meeting)\b/' => 'Florist consultation',
            '/\b(rehearsal)\b.*\b(dinner|meal)\b/' => 'Rehearsal dinner',
            '/\b(photo|photographer|photography)\b.*\b(call|consult|meeting|shot)\b/' => 'Photography planning',
            '/\b(send|invite|invitation|rsvp)\b/' => 'Invitation follow-up',
            '/\b(pay|payment|deposit|invoice|balance)\b/' => 'Payment follow-up',
        ];

        foreach ($patterns as $pattern => $label) {
            if (preg_match($pattern, $text)) {
                return $label;
            }
        }

        return Str::headline($raw);
    }

    private function recentActivity($wedding, ?array $weatherSnapshot): Collection
    {
        $activities = collect();

        $wedding->tasks()
            ->where('updated_at', '>=', now()->subDays(30))
            ->orderByDesc('updated_at')
            ->limit(4)
            ->get(['id', 'title', 'completed', 'updated_at'])
            ->each(function ($task) use ($activities) {
                $activities->push($this->activityItem(
                    $task->completed ? 'Task completed' : 'Task updated',
                    $task->completed
                        ? "{$this->momentTitle($task->title)} completed"
                        : "{$this->momentTitle($task->title)} updated",
                    'task',
                    'tasks',
                    $task->updated_at
                ));
            });

        $wedding->guests()
            ->whereNotNull('attending_status')
            ->where('attending_status', '!=', 'pending')
            ->orderByDesc('updated_at')
            ->limit(4)
            ->get(['id', 'first_name', 'last_name', 'attending_status', 'updated_at'])
            ->each(function ($guest) use ($activities) {
                $status = $guest->attending_status === 'yes'
                    ? 'accepted'
                    : ($guest->attending_status === 'no' ? 'declined' : 'updated');
                $name = $guest->full_name ?: 'Guest';
                $activities->push($this->activityItem(
                    'Guest RSVP',
                    "{$name} {$status} the invitation",
                    'rsvp',
                    'guests',
                    $guest->updated_at
                ));
            });

        $wedding->timelineItems()
            ->reorder()
            ->where('updated_at', '>=', now()->subDays(30))
            ->orderByDesc('updated_at')
            ->limit(4)
            ->get(['id', 'title', 'updated_at'])
            ->each(function ($item) use ($activities) {
                $activities->push($this->activityItem(
                    'Timeline updated',
                    "{$this->momentTitle($item->title)} updated on the timeline",
                    'timeline',
                    'timeline',
                    $item->updated_at
                ));
            });

        $wedding->galleryAssets()
            ->where('type', 'document')
            ->orderByDesc('created_at')
            ->limit(4)
            ->get(['id', 'original_filename', 'caption', 'created_at'])
            ->each(function ($asset) use ($activities) {
                $name = $asset->original_filename ?: ($asset->caption ?: 'Document');
                $activities->push($this->activityItem(
                    'Document uploaded',
                    Str::headline($name) . ' uploaded',
                    'document',
                    'documents',
                    $asset->created_at
                ));
            });

        if ($weatherSnapshot !== null) {
            $condition = $weatherSnapshot['wedding_day']['condition']
                ?? $weatherSnapshot['condition']
                ?? 'forecast';
            $activities->push($this->activityItem(
                'Weather updated',
                "Wedding day weather forecast updated: {$condition}",
                'weather',
                'weather',
                now()
            ));
        }

        return $activities
            ->sortByDesc('sort_at')
            ->take(6)
            ->values()
            ->map(fn ($item) => collect($item)->except('sort_at')->all());
    }

    private function activityItem(string $title, string $message, string $type, string $target, $at): array
    {
        return [
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'target' => $target,
            'created_at' => $at?->toISOString(),
            'time_ago' => $this->activityTimeAgo($at),
            'sort_at' => $at?->timestamp ?? 0,
        ];
    }

    private function activityTimeAgo($at): ?string
    {
        if (! $at) {
            return null;
        }

        $minutes = max(0, (int) $at->diffInMinutes(now()));
        if ($minutes < 60) {
            return $minutes <= 1 ? 'Just now' : "{$minutes}m ago";
        }

        $hours = (int) floor($minutes / 60);
        if ($hours < 24) {
            return "{$hours}h ago";
        }

        $days = (int) floor($hours / 24);
        return $days === 1 ? 'Yesterday' : "{$days}d ago";
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
