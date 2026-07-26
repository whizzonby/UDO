<?php

namespace App\Services;

use App\Mail\TemplatedMail;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;

class SubscriptionEntitlementService
{
    private const LIFETIME_PRICE = 45;
    public const PLANS = [
        'free' => [
            'label' => 'Free',
            'description' => 'For trying Udo with a small planning circle.',
            'monthly_price' => 0,
            'annual_price' => 0,
            'features' => [
                'Core planning dashboard',
                'Guest portal and RSVP',
                'Basic registry and gallery',
            ],
            'limits' => [
                'guests' => 50,
                'team_members' => 1,
                'messages_per_month' => 100,
                'gallery_assets' => 100,
                'weddings' => 1,
            ],
        ],
        'starter' => [
            'label' => 'Starter',
            'description' => 'For intimate weddings that need real guest operations.',
            'monthly_price' => 29,
            'annual_price' => 290,
            'features' => [
                'Expanded guest list',
                'Invitation campaigns',
                'Registry and thank-you tracking',
                'Gallery moderation',
            ],
            'limits' => [
                'guests' => 150,
                'team_members' => 3,
                'messages_per_month' => 500,
                'gallery_assets' => 500,
                'weddings' => 1,
            ],
        ],
        'pro' => [
            'label' => 'Pro',
            'description' => 'For full-scale planning with vendors, budget, messaging, and live mode.',
            'monthly_price' => 79,
            'annual_price' => 790,
            'recommended' => true,
            'features' => [
                'Vendor CRM',
                'Budget and payment schedules',
                'Smart alerts and automations',
                'Live operations mode',
                'Multi-wedding workspaces',
            ],
            'limits' => [
                'guests' => 500,
                'team_members' => 10,
                'messages_per_month' => 2500,
                'gallery_assets' => 2500,
                'weddings' => 5,
            ],
        ],
        'elite' => [
            'label' => 'Elite',
            'description' => 'For planners, destination weddings, and white-glove coordination.',
            'monthly_price' => 199,
            'annual_price' => 1990,
            'features' => [
                'Unlimited usage',
                'Priority support',
                'Internal ops diagnostics',
                'High-volume messaging readiness',
                'Planner-grade multi-wedding operations',
            ],
            'limits' => [
                'guests' => null,
                'team_members' => null,
                'messages_per_month' => null,
                'gallery_assets' => null,
                'weddings' => null,
            ],
        ],
        // Only ever granted by CheckoutController after a real, confirmed
        // Stripe payment (see the webhook handler) — deliberately excluded
        // from BillingController::changePlan()'s free self-service switch.
        'lifetime' => [
            'label' => 'Lifetime',
            'description' => 'One payment, full access, no subscriptions.',
            'monthly_price' => 0,
            'annual_price' => 0,
            'one_time_price' => 45,
            'features' => [
                'Everything in every plan above',
                'Unlimited guests',
                'No monthly fees, ever',
            ],
            'limits' => [
                'guests' => null,
                'team_members' => null,
                'messages_per_month' => null,
                'gallery_assets' => null,
                'weddings' => null,
            ],
        ],
    ];

    /** Plans a wedding owner can freely self-select via changePlan() without paying. */
    public const SELF_SERVICE_PLANS = ['free', 'starter', 'pro', 'elite'];

    public function payloadFor(Wedding $wedding): array
    {
        $subscription = $this->subscriptionFor($wedding);
        $plan = $subscription?->plan ?: 'free';
        $definition = self::PLANS[$plan] ?? self::PLANS['free'];

        return [
            'plan' => $plan,
            'label' => $definition['label'],
            'status' => $subscription?->status ?? 'active',
            'billing_cycle' => $subscription?->billing_cycle ?? 'monthly',
            'current_period_end' => $subscription?->current_period_end?->toJSON(),
            'description' => $definition['description'],
            'features' => $definition['features'],
            'prices' => [
                'monthly' => $definition['monthly_price'],
                'annual' => $definition['annual_price'],
            ],
            'limits' => $definition['limits'],
            'usage' => $this->usageFor($wedding),
            'available_plans' => $this->planCatalogFor($wedding),
        ];
    }

    public function planCatalogFor(Wedding $wedding): array
    {
        $usage = $this->usageFor($wedding);
        $currentPlan = $this->subscriptionFor($wedding)?->plan ?: 'free';

        return collect(self::PLANS)
            ->map(fn (array $definition, string $key) => [
                'plan' => $key,
                'label' => $definition['label'],
                'description' => $definition['description'],
                'monthly_price' => $definition['monthly_price'],
                'annual_price' => $definition['annual_price'],
                'one_time_price' => $definition['one_time_price'] ?? null,
                'features' => $definition['features'],
                'limits' => $definition['limits'],
                'recommended' => (bool) ($definition['recommended'] ?? false),
                'current' => $key === $currentPlan,
                'can_change' => $this->usageFitsPlan($usage, $definition['limits']),
                'stripe_price_ids' => [
                    'monthly' => config("services.billing.stripe_prices.{$key}.monthly"),
                    'annual' => config("services.billing.stripe_prices.{$key}.annual"),
                ],
            ])
            ->values()
            ->all();
    }

    public function usageFitsPlan(array $usage, array $limits): bool
    {
        foreach ($limits as $key => $limit) {
            if ($limit !== null && ($usage[$key] ?? 0) > $limit) {
                return false;
            }
        }

        return true;
    }

    public function ensureWithinLimit(Wedding $wedding, string $key, int $additional = 1): void
    {
        $payload = $this->payloadFor($wedding);
        $limit = $payload['limits'][$key] ?? null;

        if ($limit === null) {
            return;
        }

        $current = $payload['usage'][$key] ?? 0;

        abort_if(
            $current + $additional > $limit,
            402,
            "Your {$payload['label']} plan limit for {$key} has been reached."
        );
    }

    public function subscriptionFor(Wedding $wedding): ?Subscription
    {
        return $wedding->owner
            ? $this->activeSubscriptionFor($wedding->owner)
            : null;
    }

    public function activeSubscriptionFor(User $user): ?Subscription
    {
        return $user->subscriptions()
            ->whereIn('status', ['active', 'trialing'])
            ->latest()
            ->first();
    }

    /**
     * The one real place any successful lifetime purchase, from any
     * platform (Stripe checkout, Apple IAP, Google Play Billing), ends up.
     * Sends a real receipt email with an attached invoice PDF.
     */
    public function grantLifetime(User $user, string $platform, string $transactionId): Subscription
    {
        $subscription = $user->subscriptions()->latest()->first() ?? new Subscription(['user_id' => $user->id]);
        $subscription->fill([
            'plan' => 'lifetime',
            'status' => 'active',
            'billing_cycle' => 'one_time',
            'amount' => self::LIFETIME_PRICE,
            'currency' => 'USD',
            'current_period_start' => now(),
            'current_period_end' => null,
            'ends_at' => null,
            'platform' => $platform,
            'platform_transaction_id' => $transactionId,
            'metadata' => [
                ...($subscription->metadata ?? []),
                'lifetime_purchase_at' => now()->toISOString(),
            ],
        ]);
        $subscription->save();

        $this->sendReceipt($subscription);

        return $subscription;
    }

    private function sendReceipt(Subscription $subscription): void
    {
        $subscription->loadMissing('user');
        $invoicePath = app(InvoiceService::class)->generate($subscription);

        Mail::to($subscription->user)->send(
            (new TemplatedMail('purchase_receipt', [
                'first_name' => $subscription->user->first_name ?? $subscription->user->full_name,
                'plan_label' => self::PLANS[$subscription->plan]['label'] ?? $subscription->plan,
                'amount' => '$' . number_format((float) $subscription->amount, 2),
                'date' => $subscription->current_period_start?->format('M j, Y') ?? now()->format('M j, Y'),
            ]))->attach(Storage::disk('local')->path($invoicePath), ['as' => 'udo-invoice.pdf', 'mime' => 'application/pdf'])
        );
    }

    private function usageFor(Wedding $wedding): array
    {
        return [
            'guests' => $wedding->guests()->count(),
            'team_members' => $wedding->collaborators()->count(),
            'messages_per_month' => $wedding->messages()
                ->where('created_at', '>=', now()->startOfMonth())
                ->count(),
            'gallery_assets' => $wedding->galleryAssets()->count(),
            'weddings' => $wedding->owner
                ? $wedding->owner->ownedWeddings()->count()
                : 1,
        ];
    }
}
