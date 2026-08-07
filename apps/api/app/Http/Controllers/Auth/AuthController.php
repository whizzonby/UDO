<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Mail\TemplatedMail;
use App\Models\User;
use App\Models\Wedding;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'first_name' => 'required|string|max:100',
            'last_name'  => 'required|string|max:100',
            'email'      => 'required|email|unique:users,email',
            'password'   => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name'       => $data['first_name'] . ' ' . $data['last_name'],
            'first_name' => $data['first_name'],
            'last_name'  => $data['last_name'],
            'email'      => $data['email'],
            'password'   => Hash::make($data['password']),
        ]);

        $token = $user->createToken('api')->plainTextToken;

        Mail::to($user)->send(new TemplatedMail('welcome', [
            'first_name' => $user->first_name,
            'last_name'  => $user->last_name,
        ]));
        $user->sendEmailVerificationNotification();

        return response()->json([
            'token' => $token,
            'user'  => $this->userPayload($user),
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['These credentials do not match our records.'],
            ]);
        }

        if ($user->two_factor_enabled) {
            return response()->json($this->issueTwoFactorChallenge($user));
        }

        $user->tokens()->where('name', 'api')->delete();
        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $this->userPayload($user),
        ]);
    }

    public function twoFactorVerify(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => 'required|email',
            'two_factor_token' => 'required|string',
            'code' => 'required|string',
        ]);

        $user = User::where('email', $data['email'])->first();

        $invalidChallenge = ! $user
            || ! $user->two_factor_challenge_token
            || ! hash_equals($user->two_factor_challenge_token, $data['two_factor_token']);

        if ($invalidChallenge) {
            throw ValidationException::withMessages([
                'code' => ['This verification session has expired. Please sign in again.'],
            ]);
        }

        if ($user->two_factor_expires_at && $user->two_factor_expires_at->isPast()) {
            $this->clearTwoFactorChallenge($user);
            throw ValidationException::withMessages([
                'code' => ['This code has expired. Please sign in again to get a new one.'],
            ]);
        }

        if ($user->two_factor_attempts >= 5) {
            $this->clearTwoFactorChallenge($user);
            throw ValidationException::withMessages([
                'code' => ['Too many incorrect attempts. Please sign in again to get a new code.'],
            ]);
        }

        if (! Hash::check($data['code'], (string) $user->two_factor_code)) {
            $user->increment('two_factor_attempts');

            if ($user->fresh()->two_factor_attempts >= 5) {
                $this->clearTwoFactorChallenge($user);
                throw ValidationException::withMessages([
                    'code' => ['Too many incorrect attempts. Please sign in again to get a new code.'],
                ]);
            }

            throw ValidationException::withMessages([
                'code' => ['Incorrect code. Please try again.'],
            ]);
        }

        $this->clearTwoFactorChallenge($user);
        $user->tokens()->where('name', 'api')->delete();
        $token = $user->createToken('api')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $this->userPayload($user),
        ]);
    }

    public function twoFactorResend(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => 'required|email',
            'two_factor_token' => 'required|string',
        ]);

        $user = User::where('email', $data['email'])->first();

        $invalidChallenge = ! $user
            || ! $user->two_factor_challenge_token
            || ! hash_equals($user->two_factor_challenge_token, $data['two_factor_token']);

        if ($invalidChallenge) {
            throw ValidationException::withMessages([
                'code' => ['This verification session has expired. Please sign in again.'],
            ]);
        }

        return response()->json($this->issueTwoFactorChallenge($user));
    }

    public function twoFactorEnable(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate(['current_password' => 'nullable|string']);

        if (! $user->auth_provider && ! Hash::check((string) ($data['current_password'] ?? ''), $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->update(['two_factor_enabled' => true]);

        return response()->json([
            'message' => 'Two-factor authentication turned on.',
            'user' => $this->userPayload($user->fresh()),
        ]);
    }

    public function twoFactorDisable(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate(['current_password' => 'nullable|string']);

        if (! $user->auth_provider && ! Hash::check((string) ($data['current_password'] ?? ''), $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->update(['two_factor_enabled' => false]);

        return response()->json([
            'message' => 'Two-factor authentication turned off.',
            'user' => $this->userPayload($user->fresh()),
        ]);
    }

    /**
     * Issues a fresh emailed login code, replacing any previous pending
     * challenge for this user (only the most recent one is ever valid).
     */
    private function issueTwoFactorChallenge(User $user): array
    {
        $code = (string) random_int(100000, 999999);

        $user->forceFill([
            'two_factor_code' => Hash::make($code),
            'two_factor_challenge_token' => Str::random(48),
            'two_factor_expires_at' => now()->addMinutes(10),
            'two_factor_attempts' => 0,
        ])->save();

        Mail::to($user)->send(new TemplatedMail('two_factor_code', [
            'first_name' => $user->first_name ?: 'there',
            'code' => $code,
        ]));

        return [
            'two_factor_required' => true,
            'two_factor_token' => $user->two_factor_challenge_token,
            'message' => 'We emailed a 6-digit code to ' . $this->maskEmail($user->email) . '.',
        ];
    }

    private function clearTwoFactorChallenge(User $user): void
    {
        $user->forceFill([
            'two_factor_code' => null,
            'two_factor_challenge_token' => null,
            'two_factor_expires_at' => null,
            'two_factor_attempts' => 0,
        ])->save();
    }

    private function maskEmail(string $email): string
    {
        [$name, $domain] = array_pad(explode('@', $email, 2), 2, '');
        $visible = mb_substr($name, 0, 1);

        return $visible . str_repeat('*', max(mb_strlen($name) - 1, 1)) . '@' . $domain;
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json($this->userPayload($request->user()));
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'first_name' => 'required|string|max:100',
            'last_name'  => 'nullable|string|max:100',
            'email'      => ['required', 'email', Rule::unique('users', 'email')->ignore($user->id)],
            'avatar_url' => 'nullable|url|max:500',
        ]);

        $user->update([
            'name'       => trim($data['first_name'] . ' ' . ($data['last_name'] ?? '')),
            'first_name' => $data['first_name'],
            'last_name'  => $data['last_name'] ?? '',
            'email'      => $data['email'],
            'avatar_url' => $data['avatar_url'] ?? $user->avatar_url,
        ]);

        return response()->json($this->userPayload($user->fresh()));
    }

    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();

        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->update(['password' => Hash::make($data['password'])]);

        return response()->json(['message' => 'Password updated.']);
    }

    public function updatePreferences(Request $request): JsonResponse
    {
        $data = $request->validate([
            'notification_preferences' => 'nullable|array',
            'notification_preferences.rsvp_updates' => 'boolean',
            'notification_preferences.task_reminders' => 'boolean',
            'notification_preferences.guest_messages' => 'boolean',
            'notification_preferences.live_mode' => 'boolean',
            'notification_preferences.vendor_updates' => 'boolean',
            'support_preferences' => 'nullable|array',
            'support_preferences.email_support' => 'boolean',
            'support_preferences.chat_support' => 'boolean',
            'support_preferences.proactive_checkins' => 'boolean',
            'support_preferences.response_time' => 'nullable|string|in:within-1h,within-24h,within-3d',
        ]);

        $user = $request->user();
        $user->update([
            'notification_preferences' => array_merge(
                $this->defaultNotificationPreferences(),
                $user->notification_preferences ?? [],
                $data['notification_preferences'] ?? []
            ),
            'support_preferences' => array_merge(
                $this->defaultSupportPreferences(),
                $user->support_preferences ?? [],
                $data['support_preferences'] ?? []
            ),
        ]);

        return response()->json($this->userPayload($user->fresh()));
    }


    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function logoutAll(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json(['message' => 'All sessions have been logged out.']);
    }

    public function privacyExport(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'ownedWeddings:id,title,couple_name_primary,couple_name_secondary,event_date,city,country,owner_user_id,status',
            'collaborations.wedding:id,title,couple_name_primary,couple_name_secondary,event_date,city,country,status',
            'subscription:subscriptions.id,subscriptions.user_id,subscriptions.plan,subscriptions.status,subscriptions.current_period_end',
        ]);

        return response()->json([
            'generated_at' => now()->toISOString(),
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'email' => $user->email,
                'phone' => $user->phone,
                'avatar_url' => $user->avatar_url,
                'auth_provider' => $user->auth_provider,
                'active_wedding_id' => $user->active_wedding_id,
                'notification_preferences' => array_merge($this->defaultNotificationPreferences(), $user->notification_preferences ?? []),
                'support_preferences' => array_merge($this->defaultSupportPreferences(), $user->support_preferences ?? []),
                'email_verified_at' => $user->email_verified_at?->toISOString(),
                'created_at' => $user->created_at?->toISOString(),
                'updated_at' => $user->updated_at?->toISOString(),
            ],
            'owned_weddings' => $user->ownedWeddings->map(fn (Wedding $wedding) => [
                'id' => $wedding->id,
                'title' => $wedding->title,
                'couple_name_primary' => $wedding->couple_name_primary,
                'couple_name_secondary' => $wedding->couple_name_secondary,
                'event_date' => $wedding->event_date?->toDateString(),
                'city' => $wedding->city,
                'country' => $wedding->country,
                'status' => $wedding->status,
            ])->values(),
            'collaborations' => $user->collaborations->map(fn ($collaboration) => [
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
            ])->values(),
            'subscription' => $user->subscription ? [
                'plan' => $user->subscription->plan,
                'status' => $user->subscription->status,
                'current_period_end' => $user->subscription->current_period_end?->toISOString(),
            ] : null,
        ]);
    }

    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'confirmation' => 'required|string|in:DELETE',
            'current_password' => 'nullable|string',
        ]);

        if (! $user->auth_provider && ! Hash::check((string) ($data['current_password'] ?? ''), $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is required to delete this account.'],
            ]);
        }

        $user->tokens()->delete();
        $user->collaborations()->delete();
        $user->update([
            'name' => 'Deleted User',
            'first_name' => 'Deleted',
            'last_name' => 'User',
            'email' => "deleted-user-{$user->id}@udo.invalid",
            'phone' => null,
            'avatar_url' => null,
            'auth_provider' => 'deleted',
            'auth_provider_id' => null,
            'active_wedding_id' => null,
            'notification_preferences' => [],
            'support_preferences' => [
                ...$this->defaultSupportPreferences(),
                'account_deleted_at' => now()->toISOString(),
            ],
            'password' => Hash::make(Str::random(64)),
        ]);

        return response()->json(['message' => 'Account deleted and personal profile data anonymized.']);
    }

    private function userPayload(User $user): array
    {
        $wedding = $user->activeWedding;
        $access = app(WeddingAccessService::class)->payloadFor($user, $wedding);
        $subscription = $wedding
            ? app(SubscriptionEntitlementService::class)->payloadFor($wedding)
            : null;

        return [
            'id'                   => $user->id,
            'email'                => $user->email,
            'first_name'           => $user->first_name,
            'last_name'            => $user->last_name,
            'avatar_url'           => $user->avatar_url,
            'notification_preferences' => array_merge($this->defaultNotificationPreferences(), $user->notification_preferences ?? []),
            'support_preferences'  => array_merge($this->defaultSupportPreferences(), $user->support_preferences ?? []),
            'wedding_id'           => $user->active_wedding_id,
            'wedding_role'         => $access['role'],
            'wedding_permissions'  => $access['permissions'],
            'is_wedding_owner'     => $access['is_owner'],
            'subscription'         => $subscription,
            'onboarding_completed' => $user->onboarding_completed,
            'two_factor_enabled'   => (bool) $user->two_factor_enabled,
            'email_verified'       => $user->hasVerifiedEmail(),
            'roles'                => $user->getRoleNames()->values(),
            'is_admin'             => $user->hasRole(['super_admin', 'admin']),
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
