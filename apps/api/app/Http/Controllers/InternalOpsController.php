<?php

namespace App\Http\Controllers;

use App\Models\GuestMessageDelivery;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Wedding;
use App\Services\OperationalHealthService;
use App\Services\SubscriptionEntitlementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InternalOpsController extends Controller
{
    public function index(Request $request, OperationalHealthService $health): JsonResponse
    {
        $this->authorizeOps($request);
        $search = trim((string) $request->query('q', ''));

        $users = User::query()
            ->with('subscription')
            ->when($search !== '', fn ($query) => $query->where(function ($q) use ($search) {
                $q->where('email', 'like', "%{$search}%")
                    ->orWhere('first_name', 'like', "%{$search}%")
                    ->orWhere('last_name', 'like', "%{$search}%");
            }))
            ->latest()
            ->limit(10)
            ->get()
            ->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $user->full_name,
                'email' => $user->email,
                'active_wedding_id' => $user->active_wedding_id,
                'plan' => $user->subscription?->plan ?? 'free',
                'subscription_status' => $user->subscription?->status ?? 'active',
                'created_at' => $user->created_at?->toISOString(),
            ]);

        $weddings = Wedding::query()
            ->with('owner:id,first_name,last_name,email')
            ->withCount(['guests', 'messages', 'auditLogs'])
            ->when($search !== '', fn ($query) => $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('couple_name_primary', 'like', "%{$search}%")
                    ->orWhere('couple_name_secondary', 'like', "%{$search}%")
                    ->orWhere('slug', 'like', "%{$search}%");
            }))
            ->latest()
            ->limit(10)
            ->get()
            ->map(fn (Wedding $wedding) => [
                'id' => $wedding->id,
                'title' => $wedding->title ?: trim($wedding->couple_name_primary . ' & ' . $wedding->couple_name_secondary, ' &'),
                'owner_email' => $wedding->owner?->email,
                'event_date' => $wedding->event_date?->toDateString(),
                'guests_count' => $wedding->guests_count,
                'messages_count' => $wedding->messages_count,
                'audit_logs_count' => $wedding->audit_logs_count,
            ]);

        $deliveryDiagnostics = GuestMessageDelivery::query()
            ->with(['message:id,wedding_id,subject,channel,status', 'guest:id,first_name,last_name,email'])
            ->whereIn('status', ['failed', 'pending'])
            ->latest()
            ->limit(15)
            ->get()
            ->map(fn (GuestMessageDelivery $delivery) => [
                'id' => $delivery->id,
                'status' => $delivery->status,
                'channel' => $delivery->channel,
                'message_subject' => $delivery->message?->subject,
                'message_status' => $delivery->message?->status,
                'guest_name' => trim(($delivery->guest?->first_name ?? '') . ' ' . ($delivery->guest?->last_name ?? '')),
                'guest_email' => $delivery->guest?->email,
                'error_message' => $delivery->error_message,
                'created_at' => $delivery->created_at?->toISOString(),
            ]);

        return response()->json([
            'data' => [
                'summary' => [
                    'users' => User::count(),
                    'weddings' => Wedding::count(),
                    'active_paid_subscriptions' => Subscription::where('status', 'active')->where('plan', '!=', 'free')->count(),
                ],
                'health' => $health->snapshot(),
                'users' => $users,
                'weddings' => $weddings,
                'delivery_diagnostics' => $deliveryDiagnostics,
                'plans' => array_keys(SubscriptionEntitlementService::PLANS),
            ],
        ]);
    }

    public function overrideEntitlement(Request $request, User $user): JsonResponse
    {
        $this->authorizeOps($request);

        $data = $request->validate([
            'plan' => 'required|in:free,starter,pro,elite',
            'status' => 'required|in:active,trialing,cancelled,past_due,expired',
            'billing_cycle' => 'nullable|in:monthly,annual',
            'note' => 'required|string|max:500',
            'confirm' => 'accepted',
        ]);

        $subscription = $user->subscriptions()->latest()->first();
        if (! $subscription) {
            $subscription = new Subscription(['user_id' => $user->id]);
        }

        $subscription->fill([
            'plan' => $data['plan'],
            'status' => $data['status'],
            'billing_cycle' => $data['billing_cycle'] ?? $subscription->billing_cycle ?? 'monthly',
            'metadata' => [
                ...($subscription->metadata ?? []),
                'last_ops_override' => [
                    'by_user_id' => $request->user()->id,
                    'note' => $data['note'],
                    'at' => now()->toISOString(),
                ],
            ],
        ]);
        $subscription->save();

        return response()->json([
            'data' => [
                'user_id' => $user->id,
                'plan' => $subscription->plan,
                'status' => $subscription->status,
                'billing_cycle' => $subscription->billing_cycle,
                'metadata' => $subscription->metadata,
            ],
        ]);
    }

    private function authorizeOps(Request $request): void
    {
        abort_unless($request->user()?->hasAnyRole(['super_admin', 'admin', 'ops_admin']), 403, 'Internal operations access is required.');
    }
}
