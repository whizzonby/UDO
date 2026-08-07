<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Wedding;
use App\Models\WeddingCollaborator;
use App\Services\AuditLogService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WeddingTeamController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $access = app(WeddingAccessService::class);

        abort_unless($access->can($request->user(), $wedding, 'manage_team'), 403);

        $owner = $this->memberPayload($wedding->owner, 'owner', WeddingAccessService::PERMISSIONS, true);
        $collaborators = $wedding->collaborators()
            ->with('user')
            ->orderBy('role')
            ->get()
            ->map(fn (WeddingCollaborator $collaborator) => $this->memberPayload(
                $collaborator->user,
                $collaborator->role,
                $access->normalizePermissions($collaborator->role, $collaborator->permissions),
                false,
                $collaborator
            ))
            ->values();

        return response()->json([
            'data' => collect([$owner])->merge($collaborators)->values(),
            'roles' => $access->roleOptions(),
            'permissions' => WeddingAccessService::PERMISSIONS,
            'approval_categories' => WeddingAccessService::APPROVAL_CATEGORIES,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $access = app(WeddingAccessService::class);

        abort_unless($access->can($request->user(), $wedding, 'manage_team'), 403);

        $data = $request->validate([
            'email' => 'required|email|exists:users,email',
            'role' => ['required', 'string', Rule::in(collect($access->roleOptions())->pluck('role')->all())],
            'permissions' => 'nullable|array',
            'permissions.*' => ['string', Rule::in(WeddingAccessService::PERMISSIONS)],
            'is_decision_maker' => 'nullable|boolean',
            'approval_categories' => 'nullable|array',
            'approval_categories.*' => ['string', Rule::in(WeddingAccessService::APPROVAL_CATEGORIES)],
        ], [
            'email.exists' => "No Udo account exists with that email yet. They'll need to sign up first — then you can add them as a collaborator.",
        ]);

        $user = User::where('email', $data['email'])->firstOrFail();
        abort_if($user->id === $wedding->owner_user_id, 422, 'The owner already has full access.');

        $existing = WeddingCollaborator::where('wedding_id', $wedding->id)
            ->where('user_id', $user->id)
            ->exists();

        if (! $existing) {
            app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'team_members');
        }

        $collaborator = WeddingCollaborator::updateOrCreate(
            [
                'wedding_id' => $wedding->id,
                'user_id' => $user->id,
            ],
            [
                'role' => $data['role'],
                'permissions' => $access->normalizePermissions($data['role'], $data['permissions'] ?? null),
                'is_decision_maker' => $data['is_decision_maker'] ?? false,
                'approval_categories' => $data['approval_categories'] ?? null,
                'invited_by' => $request->user()->id,
                'accepted_at' => now(),
            ]
        );

        if (! $user->active_wedding_id) {
            $user->update(['active_wedding_id' => $wedding->id]);
        }

        app(AuditLogService::class)->record('team.member_added', $wedding, $request->user(), $collaborator, null, [
            'user_id' => $user->id,
            'email' => $user->email,
            'role' => $collaborator->role,
            'permissions' => $collaborator->permissions,
        ], request: $request);

        return response()->json([
            'data' => $this->memberPayload(
                $user,
                $collaborator->role,
                $access->normalizePermissions($collaborator->role, $collaborator->permissions),
                false,
                $collaborator
            ),
        ], 201);
    }

    public function update(Request $request, WeddingCollaborator $collaborator): JsonResponse
    {
        $wedding = $this->wedding($request);
        $access = app(WeddingAccessService::class);

        abort_unless($access->can($request->user(), $wedding, 'manage_team'), 403);
        abort_unless($collaborator->wedding_id === $wedding->id, 403);

        $data = $request->validate([
            'role' => ['sometimes', 'string', Rule::in(collect($access->roleOptions())->pluck('role')->all())],
            'permissions' => 'nullable|array',
            'permissions.*' => ['string', Rule::in(WeddingAccessService::PERMISSIONS)],
            'is_decision_maker' => 'sometimes|boolean',
            'approval_categories' => 'nullable|array',
            'approval_categories.*' => ['string', Rule::in(WeddingAccessService::APPROVAL_CATEGORIES)],
        ]);

        $role = $data['role'] ?? $collaborator->role;
        $permissions = array_key_exists('permissions', $data)
            ? $data['permissions']
            : ($role === $collaborator->role ? $collaborator->permissions : null);
        $before = $collaborator->only(['role', 'permissions', 'is_decision_maker', 'approval_categories']);

        $collaborator->update([
            'role' => $role,
            'permissions' => $access->normalizePermissions($role, $permissions),
            'is_decision_maker' => $data['is_decision_maker'] ?? $collaborator->is_decision_maker,
            'approval_categories' => array_key_exists('approval_categories', $data) ? $data['approval_categories'] : $collaborator->approval_categories,
        ]);
        $fresh = $collaborator->fresh();
        [$beforeChanged, $afterChanged] = app(AuditLogService::class)->changes($before, $fresh->only(['role', 'permissions', 'is_decision_maker', 'approval_categories']), ['role', 'permissions', 'is_decision_maker', 'approval_categories']);

        if ($afterChanged) {
            app(AuditLogService::class)->record('team.member_updated', $wedding, $request->user(), $fresh, $beforeChanged, $afterChanged, request: $request);
        }

        return response()->json([
            'data' => $this->memberPayload(
                $fresh->user,
                $fresh->role,
                $access->normalizePermissions($fresh->role, $fresh->permissions),
                false,
                $fresh
            ),
        ]);
    }

    public function destroy(Request $request, WeddingCollaborator $collaborator): JsonResponse
    {
        $wedding = $this->wedding($request);
        $access = app(WeddingAccessService::class);

        abort_unless($access->can($request->user(), $wedding, 'manage_team'), 403);
        abort_unless($collaborator->wedding_id === $wedding->id, 403);

        $before = $collaborator->load('user')->toArray();
        $collaborator->delete();
        app(AuditLogService::class)->record('team.member_removed', $wedding, $request->user(), $collaborator, $before, null, request: $request);

        return response()->json(null, 204);
    }

    private function memberPayload(User $user, string $role, array $permissions, bool $isOwner, ?WeddingCollaborator $collaborator = null): array
    {
        return [
            'id' => $collaborator?->id,
            'user_id' => $user->id,
            'name' => $user->full_name,
            'email' => $user->email,
            'avatar_url' => $user->avatar_url,
            'role' => $role,
            'permissions' => $permissions,
            'is_owner' => $isOwner,
            'is_decision_maker' => $collaborator?->is_decision_maker ?? false,
            'approval_categories' => $collaborator?->approval_categories ?? [],
            'accepted_at' => $collaborator?->accepted_at?->toJSON(),
        ];
    }
}
