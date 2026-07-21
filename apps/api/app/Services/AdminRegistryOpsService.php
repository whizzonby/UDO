<?php

namespace App\Services;

use App\Models\RegistryContribution;
use App\Models\ThankYouRecord;
use App\Models\User;
use Illuminate\Support\Arr;

class AdminRegistryOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function markContributionPaid(RegistryContribution $contribution, User $actor): RegistryContribution
    {
        $before = Arr::only($contribution->toArray(), ['payment_status', 'paid_at']);

        $contribution->forceFill([
            'payment_status' => 'completed',
            'paid_at' => now(),
        ])->save();

        $this->auditLogService->record(
            'admin.registry_contribution_marked_paid',
            wedding: $contribution->wedding,
            user: $actor,
            auditable: $contribution,
            before: $before,
            after: Arr::only($contribution->fresh()->toArray(), ['payment_status', 'paid_at']),
            metadata: ['registry_item_id' => $contribution->registry_item_id, 'guest_id' => $contribution->guest_id],
            request: request(),
        );

        return $contribution->fresh();
    }

    public function markThankYouSent(ThankYouRecord $record, User $actor, ?string $note = null, ?string $channel = null): ThankYouRecord
    {
        $before = Arr::only($record->toArray(), ['note', 'channel', 'status', 'sent_at']);

        $record->forceFill([
            'note' => $note ?: $record->note,
            'channel' => $channel ?: $record->channel ?: 'email',
            'status' => 'sent',
            'sent_at' => now(),
        ])->save();

        if ($record->contribution) {
            $record->contribution->forceFill(['thank_you_sent' => true])->save();
        }

        $this->auditLogService->record(
            'admin.thank_you_marked_sent',
            wedding: $record->wedding,
            user: $actor,
            auditable: $record,
            before: $before,
            after: Arr::only($record->fresh()->toArray(), ['note', 'channel', 'status', 'sent_at']),
            metadata: ['contribution_id' => $record->contribution_id, 'guest_id' => $record->guest_id],
            request: request(),
        );

        return $record->fresh(['contribution', 'guest']);
    }
}
