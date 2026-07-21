<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use RuntimeException;

class AdminBulkOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    /**
     * Applies the same field updates to every selected record and writes a single
     * audit entry for the batch. Refuses to run across more than one wedding, since
     * an admin table lists records from every wedding at once and an accidental
     * multi-wedding selection would otherwise leak one couple's changes into
     * another couple's data.
     *
     * @param  Collection<int, \Illuminate\Database\Eloquent\Model>  $records
     * @param  array<string, mixed>  $updates
     *
     * @throws RuntimeException if the selection spans more than one wedding.
     */
    public function applyUpdate(string $action, Collection $records, array $updates, User $actor): int
    {
        if ($records->isEmpty()) {
            return 0;
        }

        $weddingIds = $records->pluck('wedding_id')->filter()->unique();

        if ($weddingIds->count() > 1) {
            throw new RuntimeException('Selected records span more than one wedding. Refine your selection to a single wedding before running a bulk update.');
        }

        $records->each(fn ($record) => $record->forceFill($updates)->save());

        $this->auditLogService->record(
            $action,
            wedding: $records->first()->wedding,
            user: $actor,
            metadata: [
                'record_type' => $records->first()::class,
                'record_ids' => $records->pluck('id')->values()->all(),
                'updates' => $updates,
                'count' => $records->count(),
            ],
            request: request(),
        );

        return $records->count();
    }
}
