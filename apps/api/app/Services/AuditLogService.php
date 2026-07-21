<?php

namespace App\Services;

use App\Models\AuditLog;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class AuditLogService
{
    public function record(
        string $action,
        ?Wedding $wedding = null,
        ?User $user = null,
        ?Model $auditable = null,
        ?array $before = null,
        ?array $after = null,
        array $metadata = [],
        ?Request $request = null,
    ): AuditLog {
        return AuditLog::create([
            'wedding_id' => $wedding?->id,
            'user_id' => $user?->id,
            'action' => $action,
            'auditable_type' => $auditable ? $auditable::class : null,
            'auditable_id' => $auditable?->getKey(),
            'before' => $this->clean($before),
            'after' => $this->clean($after),
            'metadata' => $metadata ?: null,
            'ip_address' => $request?->ip(),
            'user_agent' => $request?->userAgent(),
        ]);
    }

    public function changes(array $before, array $after, array $keys): array
    {
        $beforeChanged = [];
        $afterChanged = [];

        foreach ($keys as $key) {
            $old = $before[$key] ?? null;
            $new = $after[$key] ?? null;

            if ($old !== $new) {
                $beforeChanged[$key] = $old;
                $afterChanged[$key] = $new;
            }
        }

        return [$this->clean($beforeChanged), $this->clean($afterChanged)];
    }

    private function clean(?array $data): ?array
    {
        if (! $data) {
            return null;
        }

        return collect($data)
            ->except(['password', 'remember_token'])
            ->all();
    }
}
