<?php

namespace App\Services;

use App\Models\BudgetPaymentSchedule;
use App\Models\SmartAlert;
use App\Models\ThankYouRecord;
use App\Models\Wedding;
use Illuminate\Support\Collection;

class SmartAlertService
{
    public function refresh(Wedding $wedding): Collection
    {
        $payloads = collect([
            $this->rsvpDeadlineAlert($wedding),
            $this->logisticsAlert($wedding),
            $this->vendorPaymentAlert($wedding),
            $this->guestReadinessAlert($wedding),
            $this->postWeddingThankYouAlert($wedding),
        ])->filter();

        $activeKeys = $payloads->pluck('key')->all();

        foreach ($payloads as $payload) {
            SmartAlert::updateOrCreate(
                ['wedding_id' => $wedding->id, 'key' => $payload['key']],
                [
                    ...$payload,
                    'wedding_id' => $wedding->id,
                    'status' => 'active',
                    'resolved_at' => null,
                    'metadata' => [
                        ...($payload['metadata'] ?? []),
                        'generated' => true,
                    ],
                ],
            );
        }

        $wedding->smartAlerts()
            ->where('status', 'active')
            ->where('metadata->generated', true)
            ->when(! empty($activeKeys), fn ($query) => $query->whereNotIn('key', $activeKeys))
            ->when(empty($activeKeys), fn ($query) => $query)
            ->update([
                'status' => 'resolved',
                'resolved_at' => now(),
            ]);

        return $this->activeAlerts($wedding);
    }

    public function activeAlerts(Wedding $wedding): Collection
    {
        return $wedding->smartAlerts()
            ->where('status', 'active')
            ->orderByRaw("case severity when 'critical' then 1 when 'high' then 2 when 'medium' then 3 else 4 end")
            ->orderBy('trigger_at')
            ->get();
    }

    public function summary(Wedding $wedding): array
    {
        $alerts = $this->refresh($wedding);

        return [
            'total_active' => $alerts->count(),
            'critical' => $alerts->where('severity', 'critical')->count(),
            'high' => $alerts->where('severity', 'high')->count(),
            'next_alert' => $alerts->first()?->only(['id', 'key', 'title', 'severity', 'target', 'trigger_at']),
            'alerts' => $alerts->map(fn (SmartAlert $alert) => $this->payload($alert))->values(),
        ];
    }

    public function payload(SmartAlert $alert): array
    {
        return [
            'id' => $alert->id,
            'key' => $alert->key,
            'alert_type' => $alert->alert_type,
            'severity' => $alert->severity,
            'status' => $alert->status,
            'target' => $alert->target,
            'title' => $alert->title,
            'body' => $alert->body,
            'action_label' => $alert->action_label,
            'action_url' => $alert->action_url,
            'trigger_at' => optional($alert->trigger_at)->toISOString(),
            'resolved_at' => optional($alert->resolved_at)->toISOString(),
            'metadata' => $alert->metadata ?? [],
        ];
    }

    private function rsvpDeadlineAlert(Wedding $wedding): ?array
    {
        $pending = $wedding->guests()->where('attending_status', 'pending')->count();
        if ($pending === 0) {
            return null;
        }

        $daysToDeadline = $wedding->rsvp_deadline ? now()->startOfDay()->diffInDays($wedding->rsvp_deadline, false) : null;
        if ($daysToDeadline !== null && $daysToDeadline > 21) {
            return null;
        }

        return [
            'key' => 'rsvp-deadline',
            'alert_type' => 'rsvp',
            'severity' => $daysToDeadline !== null && $daysToDeadline <= 3 ? 'critical' : 'high',
            'target' => 'guests',
            'title' => 'Send RSVP reminders',
            'body' => "{$pending} guest(s) still have not answered" . ($daysToDeadline !== null ? " with {$daysToDeadline} day(s) until the RSVP deadline." : '.'),
            'action_label' => 'Send reminders',
            'action_url' => '/dashboard/guests',
            'trigger_at' => $wedding->rsvp_deadline ?? now(),
            'metadata' => ['pending_guests' => $pending, 'days_to_deadline' => $daysToDeadline],
        ];
    }

    private function logisticsAlert(Wedding $wedding): ?array
    {
        $travellers = $wedding->guests()->where('travel_required', true)->get();
        $missingArrival = $travellers->filter(fn ($guest) => ! $guest->arrival_date || ! $guest->arrival_time)->count();
        $missingAccommodation = $travellers->filter(fn ($guest) => ! $guest->hotel_assignment_id)->count();
        $missingTransport = $travellers->filter(fn ($guest) => ! $guest->transport_assignment_id)->count();
        $totalMissing = $missingArrival + $missingAccommodation + $missingTransport;

        if ($totalMissing === 0) {
            return null;
        }

        return [
            'key' => 'logistics-missing',
            'alert_type' => 'logistics',
            'severity' => $totalMissing >= 5 ? 'high' : 'medium',
            'target' => 'guests',
            'title' => 'Guest logistics need follow-up',
            'body' => "{$totalMissing} travel detail(s) are missing across arrivals, accommodation, or transport.",
            'action_label' => 'Review logistics',
            'action_url' => '/dashboard/guests',
            'trigger_at' => now()->addDay(),
            'metadata' => [
                'missing_arrival_info' => $missingArrival,
                'missing_accommodation' => $missingAccommodation,
                'missing_transport' => $missingTransport,
            ],
        ];
    }

    private function vendorPaymentAlert(Wedding $wedding): ?array
    {
        $schedules = $wedding->budgetPaymentSchedules()
            ->with(['budgetItem', 'vendor'])
            ->where('status', '!=', 'paid')
            ->get();

        $dueSoon = $schedules->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->due_date && $schedule->due_date->betweenIncluded(now()->startOfDay(), now()->addDays(14)->endOfDay()));
        $overdue = $schedules->filter(fn (BudgetPaymentSchedule $schedule) => $schedule->due_date && $schedule->due_date->isPast());
        if ($dueSoon->isEmpty() && $overdue->isEmpty()) {
            return null;
        }

        $amount = (float) $dueSoon->sum('amount') + (float) $overdue->sum('amount');

        return [
            'key' => 'vendor-payments-due',
            'alert_type' => 'payment',
            'severity' => $overdue->isNotEmpty() ? 'critical' : 'high',
            'target' => 'plan',
            'title' => $overdue->isNotEmpty() ? 'Vendor payment is overdue' : 'Vendor payment due soon',
            'body' => '$' . number_format($amount, 0) . ' is due across ' . ($dueSoon->count() + $overdue->count()) . ' payment(s).',
            'action_label' => 'Review payments',
            'action_url' => '/dashboard/plan',
            'trigger_at' => optional($overdue->sortBy('due_date')->first() ?? $dueSoon->sortBy('due_date')->first())->due_date ?? now(),
            'metadata' => [
                'due_soon_count' => $dueSoon->count(),
                'overdue_count' => $overdue->count(),
                'amount_due' => $amount,
            ],
        ];
    }

    private function guestReadinessAlert(Wedding $wedding): ?array
    {
        $missingMeals = $wedding->guests()
            ->where('attending_status', 'yes')
            ->whereNull('meal_preference')
            ->count();
        $unassignedSeating = $wedding->guests()
            ->where('attending_status', 'yes')
            ->whereNull('seating_assignment_id')
            ->count();
        $vipNeedsAttention = $wedding->guests()
            ->where('vip_flag', true)
            ->where('attending_status', '!=', 'no')
            ->where(function ($query) {
                $query->whereNull('meal_preference')->orWhereNull('seating_assignment_id');
            })
            ->count();
        $totalIssues = $missingMeals + $unassignedSeating + $vipNeedsAttention;

        if ($totalIssues === 0) {
            return null;
        }

        return [
            'key' => 'guest-readiness',
            'alert_type' => 'guest',
            'severity' => $vipNeedsAttention > 0 ? 'high' : 'medium',
            'target' => 'guests',
            'title' => 'Guest readiness gaps remain',
            'body' => "{$totalIssues} meal, seating, or VIP readiness issue(s) need cleanup.",
            'action_label' => 'Review guests',
            'action_url' => '/dashboard/guests',
            'trigger_at' => now()->addDays(2),
            'metadata' => [
                'missing_meals' => $missingMeals,
                'unassigned_seating' => $unassignedSeating,
                'vip_needs_attention' => $vipNeedsAttention,
            ],
        ];
    }

    private function postWeddingThankYouAlert(Wedding $wedding): ?array
    {
        if (! $wedding->event_date || $wedding->event_date->isFuture()) {
            return null;
        }

        $pendingThanks = ThankYouRecord::query()
            ->where('wedding_id', $wedding->id)
            ->where('status', 'pending')
            ->count();

        if ($pendingThanks === 0) {
            return null;
        }

        return [
            'key' => 'post-wedding-thank-yous',
            'alert_type' => 'post_wedding',
            'severity' => 'medium',
            'target' => 'registry',
            'title' => 'Send thank-you notes',
            'body' => "{$pendingThanks} thank-you note(s) are still pending after the wedding.",
            'action_label' => 'Review thank-yous',
            'action_url' => '/dashboard/registry',
            'trigger_at' => now(),
            'metadata' => ['pending_thank_yous' => $pendingThanks],
        ];
    }
}
