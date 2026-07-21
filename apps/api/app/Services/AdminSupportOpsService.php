<?php

namespace App\Services;

use App\Models\SupportTicket;
use App\Models\User;
use Illuminate\Support\Arr;

class AdminSupportOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function assignToMe(SupportTicket $ticket, User $actor): SupportTicket
    {
        $before = Arr::only($ticket->toArray(), ['assigned_to', 'status']);
        $ticket->forceFill([
            'assigned_to' => $actor->id,
            'status' => $ticket->status === 'open' ? 'in_progress' : $ticket->status,
        ])->save();

        $this->auditLogService->record(
            'admin.support_ticket_assigned',
            wedding: $ticket->wedding,
            user: $actor,
            auditable: $ticket,
            before: $before,
            after: Arr::only($ticket->fresh()->toArray(), ['assigned_to', 'status']),
            request: request(),
        );

        return $ticket->fresh();
    }

    public function resolve(SupportTicket $ticket, User $actor): SupportTicket
    {
        $before = Arr::only($ticket->toArray(), ['status', 'resolved_at']);
        $ticket->forceFill(['status' => 'resolved'])->save();

        $this->auditLogService->record(
            'admin.support_ticket_resolved',
            wedding: $ticket->wedding,
            user: $actor,
            auditable: $ticket,
            before: $before,
            after: Arr::only($ticket->fresh()->toArray(), ['status', 'resolved_at']),
            request: request(),
        );

        return $ticket->fresh();
    }
}
