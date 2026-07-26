<?php

namespace App\Services;

use App\Models\Reminder;
use App\Models\Wedding;
use Illuminate\Support\Collection;

class ReminderService
{
    /**
     * Regenerates auto-sourced reminders from live planning data (unpaid
     * budget payment schedules, expiring insurance policies) and resolves
     * away any previously-generated reminder whose source condition no
     * longer holds — same updateOrCreate + stale-cleanup idiom as
     * SmartAlertService::refresh(), just for a different derived resource.
     */
    public function refresh(Wedding $wedding): Collection
    {
        $payloads = collect([
            ...$this->budgetPaymentReminders($wedding),
            ...$this->insuranceReminders($wedding),
        ]);

        $activeKeys = $payloads->pluck('source_key')->all();

        foreach ($payloads as $payload) {
            Reminder::updateOrCreate(
                ['wedding_id' => $wedding->id, 'source_key' => $payload['source_key']],
                [...$payload, 'wedding_id' => $wedding->id, 'source' => 'auto', 'status' => 'pending'],
            );
        }

        $wedding->reminders()
            ->where('source', 'auto')
            ->when(! empty($activeKeys), fn ($query) => $query->whereNotIn('source_key', $activeKeys))
            ->when(empty($activeKeys), fn ($query) => $query)
            ->delete();

        return $wedding->reminders()->get();
    }

    private function budgetPaymentReminders(Wedding $wedding): array
    {
        return $wedding->budgetPaymentSchedules()
            ->with(['budgetItem', 'vendor'])
            ->where('status', '!=', 'paid')
            ->whereNotNull('due_date')
            ->get()
            ->map(function ($schedule) {
                $label = $schedule->vendor?->name ?? $schedule->budgetItem?->name ?? $schedule->label;
                return [
                    'title' => trim(($label ? "$label — " : '') . ($schedule->label ?: 'Payment due')),
                    'due_date' => $schedule->due_date,
                    'priority' => $schedule->due_date->isPast() ? 'high' : 'medium',
                    'source_key' => "budget_payment_schedule:{$schedule->id}",
                    'source_description' => "Created from {$label} payment date.",
                ];
            })
            ->all();
    }

    private function insuranceReminders(Wedding $wedding): array
    {
        return $wedding->insurancePolicies()
            ->where('status', '!=', 'cancelled')
            ->whereNotNull('end_date')
            ->get()
            ->map(fn ($policy) => [
                'title' => "{$policy->provider} policy expires",
                'due_date' => $policy->end_date,
                'priority' => $policy->end_date->isPast() ? 'high' : 'low',
                'source_key' => "insurance_policy:{$policy->id}",
                'source_description' => "Created from {$policy->provider} policy expiry date.",
            ])
            ->all();
    }
}
