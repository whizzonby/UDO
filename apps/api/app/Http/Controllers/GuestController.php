<?php

namespace App\Http\Controllers;

use App\Jobs\SendGuestInviteJob;
use App\Models\AuditLog;
use App\Models\Guest;
use App\Models\GuestMessageDelivery;
use App\Models\GuestToken;
use App\Services\AuditLogService;
use App\Services\SubscriptionEntitlementService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManageGuests(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_guests'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        $guests = $this->filteredGuests($request)
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        return response()->json(['data' => $guests]);
    }

    private const ACTIVITY_LABELS = [
        'guest.created' => 'was added as a guest',
        'guest.updated' => 'details were updated',
        'guest.deleted' => 'was removed',
        'guest.invite_queued' => 'was sent an invitation',
        'guest.invite_failed' => "invitation couldn't be delivered",
        'guest.bulk_imported' => 'was imported',
        'guest.rsvp_submitted' => 'submitted their RSVP',
        'guest.hotel_assigned' => 'was assigned a hotel room',
        'guest.hotel_unassigned' => 'was unassigned from a hotel room',
        'guest.transport_assigned' => 'was assigned to a transport group',
        'guest.transport_unassigned' => 'was unassigned from a transport group',
    ];

    private function activityPayload(AuditLog $log): array
    {
        $guest = $log->auditable;
        return [
            'id' => $log->id,
            'guest_id' => $log->auditable_id,
            'guest_name' => $guest?->full_name ?? 'A guest',
            'action' => $log->action,
            'label' => self::ACTIVITY_LABELS[$log->action] ?? $log->action,
            'created_at' => $log->created_at?->toISOString(),
        ];
    }

    public function activity(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $logs = AuditLog::query()
            ->where('wedding_id', $wedding->id)
            ->where('auditable_type', Guest::class)
            ->whereIn('action', array_keys(self::ACTIVITY_LABELS))
            ->with('auditable:id,wedding_id,first_name,last_name')
            ->latest()
            ->limit(20)
            ->get();

        return response()->json(['data' => $logs->map(fn ($log) => $this->activityPayload($log))->values()]);
    }

    public function guestActivity(Request $request, Guest $guest): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($guest->wedding_id === $wedding->id, 403);

        $logs = AuditLog::query()
            ->where('wedding_id', $wedding->id)
            ->where('auditable_type', Guest::class)
            ->where('auditable_id', $guest->id)
            ->whereIn('action', array_keys(self::ACTIVITY_LABELS))
            ->with('auditable:id,wedding_id,first_name,last_name')
            ->latest()
            ->limit(50)
            ->get();

        $communications = GuestMessageDelivery::query()
            ->where('guest_id', $guest->id)
            ->with('message:id,subject,channel')
            ->latest('sent_at')
            ->limit(20)
            ->get()
            ->map(fn ($delivery) => [
                'id' => $delivery->id,
                'subject' => $delivery->message?->subject,
                'channel' => $delivery->channel,
                'status' => $delivery->status,
                'sent_at' => $delivery->sent_at?->toISOString(),
                'delivered_at' => $delivery->delivered_at?->toISOString(),
                'opened_at' => $delivery->opened_at?->toISOString(),
            ]);

        return response()->json([
            'data' => [
                'activity' => $logs->map(fn ($log) => $this->activityPayload($log))->values(),
                'communications' => $communications->values(),
            ],
        ]);
    }

    public function export(Request $request)
    {
        $guests = $this->filteredGuests($request)
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        $rows = $guests->map(fn (Guest $guest) => [
            $guest->first_name,
            $guest->last_name,
            $guest->email,
            $guest->phone,
            $guest->attending_status,
            $guest->guest_group,
            $guest->vip_flag ? 'yes' : 'no',
        ])->prepend(['first_name', 'last_name', 'email', 'phone', 'attending_status', 'guest_group', 'vip']);

        return response($this->csv($rows), 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="guests.csv"',
        ]);
    }

    private function filteredGuests(Request $request)
    {
        return $this->wedding($request)->guests()
            ->when($request->group, fn ($q) => $q->where('guest_group', $request->group))
            ->when($request->status, fn ($q) => $q->where('attending_status', $request->status))
            ->when($request->invite_status, fn ($q) => $q->where('invite_status', $request->invite_status))
            ->when($request->has('vip_flag'), fn ($q) => $q->where('vip_flag', $request->boolean('vip_flag')))
            ->when($request->has('travel_required'), fn ($q) => $q->where('travel_required', $request->boolean('travel_required')))
            ->when($request->boolean('missing_meal'), fn ($q) => $q->where('attending_status', 'yes')->whereNull('meal_preference'))
            ->when($request->boolean('missing_logistics'), fn ($q) => $q->where('travel_required', true)->where(function ($missing) {
                $missing->whereNull('arrival_date')->orWhereNull('hotel_assignment_id')->orWhereNull('transport_assignment_id');
            }))
            ->when($request->boolean('has_email'), fn ($q) => $q->whereNotNull('email')->where('email', '!=', ''))
            ->when($request->search, fn ($q) => $q->where(function ($q) use ($request) {
                $q->where('first_name', 'like', "%{$request->search}%")
                  ->orWhere('last_name', 'like', "%{$request->search}%")
                  ->orWhere('email', 'like', "%{$request->search}%")
                  ->orWhere('phone', 'like', "%{$request->search}%");
            }));
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGuests($request);
        app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'guests');

        $data = $request->validate([
            'first_name' => 'required|string|max:100',
            'last_name' => 'nullable|string|max:100',
            'email' => 'nullable|email',
            'email_opt_out' => 'boolean',
            'phone' => 'nullable|string',
            'sms_opt_out' => 'boolean',
            'whatsapp_opt_out' => 'boolean',
            'guest_group' => 'nullable|string',
            'vip_flag' => 'boolean',
            'plus_one_allowed' => 'boolean',
            'plus_one_count' => 'integer|min:0|max:5',
            'plus_one_name' => 'nullable|string|max:255',
            'plus_one_email' => 'nullable|email|max:255',
            'meal_preference' => 'nullable|string',
            'allergies' => 'nullable|string',
            'dietary_note' => 'nullable|string',
            'notes' => 'nullable|string',
            'wedding_party_role' => 'nullable|string|max:100',
            'attire_status' => 'nullable|in:not_started,ordered,fitted,ready',
            'rehearsal_status' => 'nullable|in:pending,confirmed,declined',
        ]);

        if (! empty($data['wedding_party_role'])) {
            app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'wedding_party_members');
        }

        $guest = $wedding->guests()->create($data);
        app(AuditLogService::class)->record('guest.created', $wedding, $request->user(), $guest, null, $guest->toArray(), request: $request);

        return response()->json(['data' => $guest], 201);
    }

    public function show(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        return response()->json(['data' => $guest->load('token')]);
    }

    public function update(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $this->ensureCanManageGuests($request);

        $data = $request->validate([
            'first_name' => 'sometimes|string|max:100',
            'last_name' => 'nullable|string|max:100',
            'email' => 'nullable|email',
            'email_opt_out' => 'boolean',
            'phone' => 'nullable|string',
            'sms_opt_out' => 'boolean',
            'whatsapp_opt_out' => 'boolean',
            'guest_group' => 'nullable|string',
            'custom_tags' => 'nullable|array',
            'vip_flag' => 'boolean',
            'is_elderly' => 'boolean',
            'accessibility_needs' => 'boolean',
            'attending_status' => 'nullable|in:pending,yes,no',
            'invite_status' => 'nullable|string',
            'plus_one_allowed' => 'boolean',
            'plus_one_count' => 'integer|min:0|max:5',
            'plus_one_name' => 'nullable|string|max:255',
            'plus_one_email' => 'nullable|email|max:255',
            'meal_preference' => 'nullable|string',
            'allergies' => 'nullable|string',
            'dietary_note' => 'nullable|string',
            'dietary_tags' => 'nullable|array',
            'travel_required' => 'boolean',
            'wants_accommodation' => 'nullable|boolean',
            'arrival_date' => 'nullable|date',
            'departure_date' => 'nullable|date',
            'checked_in_at' => 'nullable|date',
            'arrival_airport' => 'nullable|string',
            'song_request' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
            'wedding_party_role' => 'nullable|string|max:100',
            'attire_status' => 'nullable|in:not_started,ordered,fitted,ready',
            'rehearsal_status' => 'nullable|in:pending,confirmed,declined',
        ]);

        if (! empty($data['wedding_party_role']) && empty($guest->wedding_party_role)) {
            app(SubscriptionEntitlementService::class)->ensureWithinLimit($this->wedding($request), 'wedding_party_members');
        }

        $before = $guest->only(array_keys($data));
        $guest->update($data);
        $fresh = $guest->fresh();
        [$beforeChanged, $afterChanged] = app(AuditLogService::class)->changes($before, $fresh->only(array_keys($data)), array_keys($data));

        if ($afterChanged) {
            app(AuditLogService::class)->record('guest.updated', $this->wedding($request), $request->user(), $fresh, $beforeChanged, $afterChanged, request: $request);
        }

        return response()->json(['data' => $fresh]);
    }

    public function destroy(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $this->ensureCanManageGuests($request);
        $before = $guest->toArray();
        $guest->delete();
        app(AuditLogService::class)->record('guest.deleted', $this->wedding($request), $request->user(), $guest, $before, null, request: $request);

        return response()->json(null, 204);
    }

    public function generateToken(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $this->ensureCanManageGuests($request);

        $existing = $guest->token;
        if ($existing) {
            $existing->update(['revoked' => false]);
            return response()->json(['token' => $existing->token]);
        }

        $guestToken = GuestToken::create([
            'wedding_id' => $guest->wedding_id,
            'guest_id' => $guest->id,
            'view_type' => $guest->guest_view_type,
        ]);

        return response()->json(['token' => $guestToken->token]);
    }

    public function sendInvite(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $this->ensureCanManageGuests($request);
        if ($guest->invite_status !== 'sent') {
            app(SubscriptionEntitlementService::class)->ensureWithinLimit($this->wedding($request), 'invitations_sent');
        }

        if (! $guest->token) {
            GuestToken::create([
                'wedding_id' => $guest->wedding_id,
                'guest_id' => $guest->id,
                'view_type' => $guest->guest_view_type,
            ]);
            $guest->load('token');
        }

        if (! $guest->email) {
            $guest->update(['invite_status' => 'failed']);
            app(AuditLogService::class)->record('guest.invite_failed', $this->wedding($request), $request->user(), $guest->fresh(), null, ['invite_status' => 'failed'], [
                'reason' => 'missing_email',
            ], $request);

            return response()->json([
                'data' => $guest->fresh('token'),
                'message' => 'Guest has no email address, so the invite could not be queued.',
            ], 422);
        }

        $guest->update(['invite_status' => 'queued']);
        SendGuestInviteJob::dispatch($guest->id);
        app(AuditLogService::class)->record('guest.invite_queued', $this->wedding($request), $request->user(), $guest->fresh(), null, ['invite_status' => 'queued'], request: $request);

        return response()->json(['data' => $guest->fresh('token'), 'message' => 'Invite queued for delivery.']);
    }

    public function bulkImport(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGuests($request);

        $request->validate([
            'guests' => 'required|array|min:1',
            'guests.*.first_name' => 'required|string',
            'guests.*.last_name' => 'nullable|string',
            'guests.*.email' => 'nullable|email',
        ]);

        $guests = $request->input('guests', []);
        app(SubscriptionEntitlementService::class)->ensureWithinLimit($wedding, 'guests', count($guests));

        $created = collect($guests)->map(fn ($g) => $wedding->guests()->create($g));
        app(AuditLogService::class)->record('guest.bulk_imported', $wedding, $request->user(), null, null, [
            'imported' => $created->count(),
        ], request: $request);

        return response()->json(['data' => $created->values(), 'imported' => $created->count()]);
    }

    public function bulkUpdate(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGuests($request);

        $data = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer',
            'updates' => 'required|array',
            'updates.attending_status' => 'nullable|in:pending,yes,no',
            'updates.invite_status' => 'nullable|string|max:100',
            'updates.guest_group' => 'nullable|string|max:100',
            'updates.vip_flag' => 'nullable|boolean',
            'updates.travel_required' => 'nullable|boolean',
            'updates.meal_preference' => 'nullable|string|max:100',
            'confirm' => 'accepted',
        ]);

        $allowedUpdates = collect($data['updates'])->only([
            'attending_status',
            'invite_status',
            'guest_group',
            'vip_flag',
            'travel_required',
            'meal_preference',
        ])->all();
        abort_if(empty($allowedUpdates), 422, 'No supported updates were provided.');

        $guests = $wedding->guests()->whereIn('id', $data['ids'])->get();
        abort_unless($guests->count() === count(array_unique($data['ids'])), 422, 'One or more guests do not belong to this wedding.');

        $before = $guests->map(fn (Guest $guest) => $guest->only(array_keys($allowedUpdates)));
        $wedding->guests()->whereIn('id', $data['ids'])->update($allowedUpdates);
        app(AuditLogService::class)->record('guest.bulk_updated', $wedding, $request->user(), null, ['records' => $before], [
            'updated_ids' => $guests->pluck('id')->values()->all(),
            'updates' => $allowedUpdates,
        ], request: $request);

        return response()->json([
            'updated' => $guests->count(),
            'data' => $wedding->guests()->whereIn('id', $data['ids'])->orderBy('last_name')->orderBy('first_name')->get(),
        ]);
    }

    private function authorizeGuest(Request $request, Guest $guest): void
    {
        $wedding = $this->wedding($request);
        abort_unless($guest->wedding_id === $wedding->id, 403, 'Forbidden.');
    }

    private function csv($rows): string
    {
        return $rows->map(fn ($row) => collect($row)->map(fn ($value) => '"' . str_replace('"', '""', (string) $value) . '"')->implode(','))->implode("\n") . "\n";
    }
}
