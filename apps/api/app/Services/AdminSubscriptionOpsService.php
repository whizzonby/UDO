<?php

namespace App\Services;

use App\Models\Subscription;
use App\Models\User;
use Illuminate\Support\Arr;

class AdminSubscriptionOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function override(Subscription $subscription, User $actor, array $data): Subscription
    {
        $plan = $data['plan'];
        $billingCycle = $data['billing_cycle'] ?? $subscription->billing_cycle ?? 'monthly';
        $definition = SubscriptionEntitlementService::PLANS[$plan] ?? SubscriptionEntitlementService::PLANS['free'];
        $priceId = config("services.billing.stripe_prices.{$plan}.{$billingCycle}");
        $before = $subscription->exists ? $subscription->toArray() : null;

        $subscription->fill([
            'plan' => $plan,
            'status' => $data['status'],
            'billing_cycle' => $billingCycle,
            'amount' => $billingCycle === 'annual' ? $definition['annual_price'] : $definition['monthly_price'],
            'currency' => $data['currency'] ?? $subscription->currency ?? 'USD',
            'stripe_price_id' => $priceId ?: ($data['stripe_price_id'] ?? $subscription->stripe_price_id),
            'current_period_start' => $data['current_period_start'] ?? $subscription->current_period_start ?? now(),
            'current_period_end' => $data['current_period_end'] ?? $subscription->current_period_end ?? (
                $billingCycle === 'annual' ? now()->addYear() : now()->addMonth()
            ),
            'metadata' => [
                ...($subscription->metadata ?? []),
                'last_admin_override' => [
                    'by_user_id' => $actor->id,
                    'note' => $data['note'],
                    'plan' => $plan,
                    'status' => $data['status'],
                    'billing_cycle' => $billingCycle,
                    'stripe_price_id' => $priceId,
                    'at' => now()->toISOString(),
                ],
            ],
        ]);
        $subscription->save();

        $this->auditLogService->record(
            'admin.subscription_overridden',
            user: $actor,
            auditable: $subscription,
            before: $before ? Arr::only($before, $this->auditedKeys()) : null,
            after: Arr::only($subscription->fresh()->toArray(), $this->auditedKeys()),
            metadata: [
                'target_user_id' => $subscription->user_id,
                'note' => $data['note'],
            ],
            request: request(),
        );

        return $subscription->fresh();
    }

    private function auditedKeys(): array
    {
        return [
            'user_id',
            'plan',
            'status',
            'billing_cycle',
            'amount',
            'currency',
            'stripe_customer_id',
            'stripe_subscription_id',
            'stripe_price_id',
            'trial_ends_at',
            'current_period_start',
            'current_period_end',
            'cancelled_at',
            'ends_at',
            'metadata',
        ];
    }
}
