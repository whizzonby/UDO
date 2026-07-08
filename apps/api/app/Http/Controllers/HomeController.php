<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user    = $request->user();
        $wedding = $user->activeWedding;

        if (! $wedding) {
            return response()->json(['wedding' => null, 'stats' => [], 'upcoming_tasks' => []]);
        }

        $guestCount     = $wedding->guests()->count();
        $confirmedCount = $wedding->guests()->where('attending_status', 'attending')->count();
        $declinedCount  = $wedding->guests()->where('attending_status', 'not_attending')->count();

        $totalTasks     = $wedding->tasks()->count();
        $completedTasks = $wedding->tasks()->where('completed', true)->count();
        $pendingTasks   = $totalTasks - $completedTasks;

        $upcomingTasks = $wedding->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->orderBy('due_date')
            ->limit(5)
            ->get(['id', 'title', 'due_date', 'priority']);

        $budgetItems   = $wedding->budgetItems();
        $budgetSpent   = $budgetItems->sum('actual_amount');
        $budgetTotal   = $wedding->settings['total_budget'] ?? $budgetItems->sum('estimated_amount');

        $daysUntil = $wedding->event_date
            ? (int) now()->startOfDay()->diffInDays($wedding->event_date, false)
            : null;

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
                'pending_guests'   => $guestCount - $confirmedCount - $declinedCount,
                'total_tasks'      => $totalTasks,
                'completed_tasks'  => $completedTasks,
                'pending_tasks'    => $pendingTasks,
                'budget_spent'     => (float) $budgetSpent,
                'budget_total'     => (float) $budgetTotal,
            ],
            'upcoming_tasks' => $upcomingTasks,
        ]);
    }
}
