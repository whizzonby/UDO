<?php

namespace App\Services;

use App\Models\User;
use App\Models\Vendor;
use App\Models\VendorContactLog;
use Illuminate\Support\Arr;

class AdminVendorOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function logContact(Vendor $vendor, User $actor, array $data): VendorContactLog
    {
        $log = $vendor->contactLogs()->create([
            ...$data,
            'wedding_id' => $vendor->wedding_id,
            'created_by' => $actor->id,
            'contact_type' => $data['contact_type'] ?? 'note',
            'contact_at' => $data['contact_at'] ?? now(),
        ]);

        $this->auditLogService->record(
            'admin.vendor_contact_logged',
            wedding: $vendor->wedding,
            user: $actor,
            auditable: $log,
            after: Arr::only($log->toArray(), [
                'id',
                'vendor_id',
                'contact_type',
                'subject',
                'outcome',
                'contact_at',
                'follow_up_at',
            ]),
            metadata: ['vendor_id' => $vendor->id],
            request: request(),
        );

        return $log->fresh(['vendor', 'creator']);
    }

    public function markContractSigned(Vendor $vendor, User $actor, ?string $contractUrl = null): Vendor
    {
        $before = Arr::only($vendor->toArray(), ['contract_signed', 'contract_file_url', 'booking_status']);

        $vendor->forceFill([
            'contract_signed' => true,
            'contract_file_url' => $contractUrl ?: $vendor->contract_file_url,
            'booking_status' => in_array($vendor->booking_status, ['booked', 'confirmed', 'paid'], true)
                ? $vendor->booking_status
                : 'confirmed',
        ])->save();

        $this->auditLogService->record(
            'admin.vendor_contract_signed',
            wedding: $vendor->wedding,
            user: $actor,
            auditable: $vendor,
            before: $before,
            after: Arr::only($vendor->fresh()->toArray(), ['contract_signed', 'contract_file_url', 'booking_status']),
            metadata: ['vendor_id' => $vendor->id],
            request: request(),
        );

        return $vendor->fresh();
    }

    public function riskScore(Vendor $vendor): string
    {
        if ($vendor->booking_status === 'cancelled') {
            return 'cancelled';
        }

        $hasOverdueFollowUp = $vendor->contactLogs()
            ->whereNotNull('follow_up_at')
            ->where('follow_up_at', '<', now())
            ->exists();

        $hasOverdueTasks = $vendor->tasks()
            ->where('completed', false)
            ->whereNotNull('due_date')
            ->whereDate('due_date', '<', now()->toDateString())
            ->exists();

        if (($vendor->booking_status && in_array($vendor->booking_status, ['booked', 'confirmed', 'paid'], true) && ! $vendor->contract_signed)
            || $hasOverdueFollowUp
            || $hasOverdueTasks
            || (float) $vendor->balance_due > 0 && $vendor->balance_due_date?->isPast()) {
            return 'attention';
        }

        if ($vendor->priority === 'high' || $vendor->booking_status === 'negotiating') {
            return 'watch';
        }

        return 'healthy';
    }
}
