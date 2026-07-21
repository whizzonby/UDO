<?php

namespace App\Services;

use App\Models\FailedJob;
use App\Models\User;
use Illuminate\Support\Facades\Artisan;

class AdminReliabilityOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    /**
     * Pushes the job back onto its queue via Laravel's own retry pipeline. On
     * success this removes the row from failed_jobs, so the admin table simply
     * stops showing it rather than needing a separate "resolved" state.
     */
    public function retryFailedJob(FailedJob $job, User $actor): void
    {
        $metadata = ['uuid' => $job->uuid, 'queue' => $job->queue, 'connection' => $job->connection];

        Artisan::call('queue:retry', ['id' => [$job->uuid]]);

        $this->auditLogService->record(
            'admin.failed_job_retried',
            user: $actor,
            metadata: $metadata,
            request: request(),
        );
    }

    public function forgetFailedJob(FailedJob $job, User $actor): void
    {
        $metadata = ['uuid' => $job->uuid, 'queue' => $job->queue, 'connection' => $job->connection];

        Artisan::call('queue:forget', ['id' => $job->uuid]);

        $this->auditLogService->record(
            'admin.failed_job_forgotten',
            user: $actor,
            metadata: $metadata,
            request: request(),
        );
    }
}
