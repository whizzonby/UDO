<?php

namespace App\Services;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminAccountSafetyService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function privacyExport(User $target, ?User $actor = null): array
    {
        $target->load([
            'ownedWeddings:id,title,couple_name_primary,couple_name_secondary,event_date,city,country,owner_user_id,status',
            'collaborations.wedding:id,title,couple_name_primary,couple_name_secondary,event_date,city,country,status',
            'subscription:subscriptions.id,subscriptions.user_id,subscriptions.plan,subscriptions.status,subscriptions.current_period_end',
        ]);

        $payload = [
            'generated_at' => now()->toISOString(),
            'user' => [
                'id' => $target->id,
                'name' => $target->name,
                'first_name' => $target->first_name,
                'last_name' => $target->last_name,
                'email' => $target->email,
                'phone' => $target->phone,
                'avatar_url' => $target->avatar_url,
                'auth_provider' => $target->auth_provider,
                'active_wedding_id' => $target->active_wedding_id,
                'notification_preferences' => array_merge($this->defaultNotificationPreferences(), $target->notification_preferences ?? []),
                'support_preferences' => array_merge($this->defaultSupportPreferences(), $target->support_preferences ?? []),
                'email_verified_at' => $target->email_verified_at?->toISOString(),
                'created_at' => $target->created_at?->toISOString(),
                'updated_at' => $target->updated_at?->toISOString(),
            ],
            'owned_weddings' => $target->ownedWeddings->map(fn (Wedding $wedding) => [
                'id' => $wedding->id,
                'title' => $wedding->title,
                'couple_name_primary' => $wedding->couple_name_primary,
                'couple_name_secondary' => $wedding->couple_name_secondary,
                'event_date' => $wedding->event_date?->toDateString(),
                'city' => $wedding->city,
                'country' => $wedding->country,
                'status' => $wedding->status,
            ])->values()->all(),
            'collaborations' => $target->collaborations->map(fn ($collaboration) => [
                'wedding_id' => $collaboration->wedding_id,
                'role' => $collaboration->role,
                'permissions' => $collaboration->permissions ?? [],
                'accepted_at' => $collaboration->accepted_at?->toISOString(),
                'wedding' => $collaboration->wedding ? [
                    'title' => $collaboration->wedding->title,
                    'couple_name_primary' => $collaboration->wedding->couple_name_primary,
                    'couple_name_secondary' => $collaboration->wedding->couple_name_secondary,
                    'event_date' => $collaboration->wedding->event_date?->toDateString(),
                    'city' => $collaboration->wedding->city,
                    'country' => $collaboration->wedding->country,
                    'status' => $collaboration->wedding->status,
                ] : null,
            ])->values()->all(),
            'subscription' => $target->subscription ? [
                'plan' => $target->subscription->plan,
                'status' => $target->subscription->status,
                'current_period_end' => $target->subscription->current_period_end?->toISOString(),
            ] : null,
        ];

        $this->auditLogService->record(
            'admin.privacy_exported',
            user: $actor,
            auditable: $target,
            metadata: [
                'target_user_id' => $target->id,
                'owned_weddings' => count($payload['owned_weddings']),
                'collaborations' => count($payload['collaborations']),
            ],
            request: request(),
        );

        return $payload;
    }

    public function revokeTokens(User $target, ?User $actor = null): int
    {
        $count = $target->tokens()->count();
        $target->tokens()->delete();

        $this->auditLogService->record(
            'admin.tokens_revoked',
            user: $actor,
            auditable: $target,
            before: ['api_tokens_count' => $count],
            after: ['api_tokens_count' => 0],
            metadata: ['target_user_id' => $target->id],
            request: request(),
        );

        return $count;
    }

    public function anonymize(User $target, ?User $actor = null): array
    {
        $before = $target->only([
            'id',
            'name',
            'first_name',
            'last_name',
            'email',
            'phone',
            'avatar_url',
            'auth_provider',
            'auth_provider_id',
            'active_wedding_id',
            'notification_preferences',
            'support_preferences',
        ]);
        $tokenCount = $target->tokens()->count();
        $collaborationCount = $target->collaborations()->count();

        $target->tokens()->delete();
        $target->collaborations()->delete();
        $target->forceFill([
            'name' => 'Deleted User',
            'first_name' => 'Deleted',
            'last_name' => 'User',
            'email' => "deleted-user-{$target->id}@udo.invalid",
            'phone' => null,
            'avatar_url' => null,
            'auth_provider' => 'deleted',
            'auth_provider_id' => null,
            'active_wedding_id' => null,
            'notification_preferences' => [],
            'support_preferences' => [
                ...$this->defaultSupportPreferences(),
                'account_deleted_at' => now()->toISOString(),
                'account_deleted_by_admin_id' => $actor?->id,
            ],
            'password' => Hash::make(Str::random(64)),
        ])->save();

        $after = $target->fresh()->only(array_keys($before));

        $this->auditLogService->record(
            'admin.user_anonymized',
            user: $actor,
            auditable: $target,
            before: $before,
            after: $after,
            metadata: [
                'target_user_id' => $target->id,
                'revoked_api_tokens' => $tokenCount,
                'removed_collaborations' => $collaborationCount,
            ],
            request: request(),
        );

        return [
            'revoked_api_tokens' => $tokenCount,
            'removed_collaborations' => $collaborationCount,
        ];
    }

    private function defaultNotificationPreferences(): array
    {
        return [
            'rsvp_updates' => true,
            'task_reminders' => true,
            'guest_messages' => true,
            'live_mode' => true,
            'vendor_updates' => false,
        ];
    }

    private function defaultSupportPreferences(): array
    {
        return [
            'email_support' => true,
            'chat_support' => false,
            'proactive_checkins' => true,
            'response_time' => 'within-24h',
        ];
    }
}
