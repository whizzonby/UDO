<?php

namespace App\Services;

use App\Models\User;
use App\Models\Wedding;
use App\Models\WeddingCollaborator;

class WeddingAccessService
{
    public const PERMISSIONS = [
        'manage_wedding',
        'manage_team',
        'manage_guests',
        'manage_plan',
        'manage_budget',
        'manage_vendors',
        'manage_messages',
        'manage_registry',
        'manage_gallery',
        'manage_live',
        'view_reports',
    ];

    private const ROLE_PERMISSIONS = [
        'owner' => self::PERMISSIONS,
        'partner' => self::PERMISSIONS,
        'planner' => [
            'manage_wedding',
            'manage_team',
            'manage_guests',
            'manage_plan',
            'manage_budget',
            'manage_vendors',
            'manage_messages',
            'manage_registry',
            'manage_gallery',
            'manage_live',
            'view_reports',
        ],
        'day_of_coordinator' => [
            'manage_guests',
            'manage_plan',
            'manage_messages',
            'manage_gallery',
            'manage_live',
            'view_reports',
        ],
        'finance' => [
            'manage_budget',
            'manage_vendors',
            'manage_registry',
            'view_reports',
        ],
        'vendor' => [
            'manage_plan',
        ],
        'viewer' => [
            'view_reports',
        ],
    ];

    public function roleOptions(): array
    {
        return collect(self::ROLE_PERMISSIONS)
            ->map(fn (array $permissions, string $role) => [
                'role' => $role,
                'permissions' => $permissions,
            ])
            ->values()
            ->all();
    }

    public function payloadFor(User $user, ?Wedding $wedding): array
    {
        if (! $wedding) {
            return [
                'role' => null,
                'permissions' => [],
                'is_owner' => false,
            ];
        }

        if ($wedding->owner_user_id === $user->id) {
            return [
                'role' => 'owner',
                'permissions' => self::PERMISSIONS,
                'is_owner' => true,
            ];
        }

        $collaborator = $this->collaboratorFor($user, $wedding);

        if (! $collaborator) {
            return [
                'role' => null,
                'permissions' => [],
                'is_owner' => false,
            ];
        }

        return [
            'role' => $collaborator->role,
            'permissions' => $this->permissionsFor($collaborator),
            'is_owner' => false,
        ];
    }

    public function canAccessWedding(User $user, Wedding $wedding): bool
    {
        return $wedding->owner_user_id === $user->id
            || $this->collaboratorFor($user, $wedding) !== null;
    }

    public function can(User $user, Wedding $wedding, string $permission): bool
    {
        if ($wedding->owner_user_id === $user->id) {
            return true;
        }

        $collaborator = $this->collaboratorFor($user, $wedding);

        return $collaborator
            && in_array($permission, $this->permissionsFor($collaborator), true);
    }

    public function permissionsForRole(string $role): array
    {
        return self::ROLE_PERMISSIONS[$role] ?? self::ROLE_PERMISSIONS['viewer'];
    }

    public function normalizePermissions(string $role, ?array $permissions): array
    {
        $allowed = $permissions ?: $this->permissionsForRole($role);

        return collect($allowed)
            ->intersect(self::PERMISSIONS)
            ->values()
            ->all();
    }

    private function permissionsFor(WeddingCollaborator $collaborator): array
    {
        return $this->normalizePermissions($collaborator->role, $collaborator->permissions);
    }

    private function collaboratorFor(User $user, Wedding $wedding): ?WeddingCollaborator
    {
        return WeddingCollaborator::query()
            ->where('wedding_id', $wedding->id)
            ->where('user_id', $user->id)
            ->first();
    }
}
