<?php

namespace App\Services;

use App\Models\LiveUpdate;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Support\Arr;

class AdminLiveOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function startLive(Wedding $wedding, User $actor): Wedding
    {
        $before = Arr::only($wedding->toArray(), ['status']);
        $wedding->forceFill(['status' => 'live'])->save();

        $this->auditLogService->record(
            'admin.live_wedding_started',
            wedding: $wedding,
            user: $actor,
            auditable: $wedding,
            before: $before,
            after: Arr::only($wedding->fresh()->toArray(), ['status']),
            request: request(),
        );

        return $wedding->fresh();
    }

    public function markFinalWeek(Wedding $wedding, User $actor): Wedding
    {
        $before = Arr::only($wedding->toArray(), ['status']);
        $wedding->forceFill(['status' => 'final_week'])->save();

        $this->auditLogService->record(
            'admin.wedding_marked_final_week',
            wedding: $wedding,
            user: $actor,
            auditable: $wedding,
            before: $before,
            after: Arr::only($wedding->fresh()->toArray(), ['status']),
            request: request(),
        );

        return $wedding->fresh();
    }

    public function resolveUpdate(LiveUpdate $update, User $actor): LiveUpdate
    {
        $before = Arr::only($update->toArray(), ['status', 'requires_action', 'resolved_at']);
        $update->forceFill([
            'status' => 'resolved',
            'requires_action' => false,
            'resolved_at' => now(),
        ])->save();

        $this->auditLogService->record(
            'admin.live_update_resolved',
            wedding: $update->wedding,
            user: $actor,
            auditable: $update,
            before: $before,
            after: Arr::only($update->fresh()->toArray(), ['status', 'requires_action', 'resolved_at']),
            request: request(),
        );

        return $update->fresh();
    }
}
