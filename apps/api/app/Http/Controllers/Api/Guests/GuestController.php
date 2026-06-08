<?php

namespace App\Http\Controllers\Api\Guests;

use App\Events\ActivityRecorded;
use App\Http\Controllers\Controller;
use App\Jobs\SendGuestInvitation;
use App\Jobs\SendGuestSmsInvitation;
use App\Models\Guest;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class GuestController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        return $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();
    }

    // GET /guests
    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $query = $wedding->guests()->orderBy('sort_order')->orderBy('first_name');

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($status = $request->query('rsvp_status')) {
            $query->where('rsvp_status', $status);
        }

        if ($group = $request->query('group')) {
            $query->where('group', $group);
        }

        if ($request->query('vip')) {
            $query->where('is_vip', true);
        }

        $guests = $query->get();

        return response()->json([
            'guests' => $guests->map(fn ($g) => $this->formatGuest($g)),
            'total'  => $guests->count(),
        ]);
    }

    // GET /guests/overview
    public function overview(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $guests  = $wedding->guests;

        $invited          = $guests->count();
        $attending        = $guests->where('rsvp_status', 'attending')->count();
        $declined         = $guests->where('rsvp_status', 'declined')->count();
        $pending          = $guests->where('rsvp_status', 'pending')->count();
        $responded        = $attending + $declined;
        $responseRate     = $invited > 0 ? round($responded / $invited * 100) : 0;

        // Dietary breakdown
        $vegetarian = $guests->filter(fn ($g) => str_contains(strtolower((string) $g->dietary_requirements), 'veg'))->count();
        $allergies  = $guests->filter(fn ($g) => str_contains(strtolower((string) $g->dietary_requirements), 'allerg'))->count();
        $kids       = $guests->where('age_group', 'child')->count();
        $plusOnes   = $guests->where('plus_one_allowed', true)->count();

        // Groups
        $groups = $guests->groupBy('group')->map->count();

        return response()->json([
            'total_guests'    => $invited,
            'attending'       => $attending,
            'declined'        => $declined,
            'pending'         => $pending,
            'response_rate'   => $responseRate,
            'quick_stats' => [
                'vegetarian' => $vegetarian,
                'allergies'  => $allergies,
                'kids'       => $kids,
                'plus_ones'  => $plusOnes,
            ],
            'groups'          => $groups,
            'vip_count'       => $guests->where('is_vip', true)->count(),
            'invited_count'   => $guests->whereNotNull('invitation_sent_at')->count(),
            'not_invited_yet' => $guests->whereNull('invitation_sent_at')->count(),
        ]);
    }

    // POST /guests
    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'first_name'          => 'required|string|max:100',
            'last_name'           => 'nullable|string|max:100',
            'email'               => 'nullable|email|max:255',
            'phone'               => 'nullable|string|max:30',
            'group'               => 'nullable|string|max:100',
            'relationship'        => ['nullable', Rule::in(['bride_side', 'groom_side', 'mutual', 'other'])],
            'age_group'           => ['nullable', Rule::in(['adult', 'child', 'baby'])],
            'rsvp_status'         => ['nullable', Rule::in(['pending', 'attending', 'declined', 'maybe'])],
            'is_vip'              => 'boolean',
            'dietary_requirements' => 'nullable|string|max:500',
            'plus_one_allowed'    => 'boolean',
            'plus_one_name'       => 'nullable|string|max:200',
            'needs_transport'     => 'boolean',
            'needs_accommodation' => 'boolean',
            'notes'               => 'nullable|string|max:1000',
        ]);

        $guest = $wedding->guests()->create($data);

        return response()->json(['guest' => $this->formatGuest($guest)], 201);
    }

    // GET /guests/{guest}
    public function show(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        return response()->json(['guest' => $this->formatGuest($guest, detailed: true)]);
    }

    // PUT /guests/{guest}
    public function update(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        $data = $request->validate([
            'first_name'           => 'sometimes|string|max:100',
            'last_name'            => 'nullable|string|max:100',
            'email'                => 'nullable|email|max:255',
            'phone'                => 'nullable|string|max:30',
            'group'                => 'nullable|string|max:100',
            'relationship'         => ['nullable', Rule::in(['bride_side', 'groom_side', 'mutual', 'other'])],
            'age_group'            => ['nullable', Rule::in(['adult', 'child', 'baby'])],
            'rsvp_status'          => ['nullable', Rule::in(['pending', 'attending', 'declined', 'maybe'])],
            'is_vip'               => 'boolean',
            'dietary_requirements' => 'nullable|string|max:500',
            'plus_one_allowed'     => 'boolean',
            'plus_one_name'        => 'nullable|string|max:200',
            'needs_transport'      => 'boolean',
            'needs_accommodation'  => 'boolean',
            'notes'                => 'nullable|string|max:1000',
            'address'              => 'nullable|string|max:500',
            'language'             => 'nullable|string|max:50',
        ]);

        if (isset($data['rsvp_status']) && $data['rsvp_status'] !== $guest->rsvp_status) {
            $data['rsvp_responded_at'] = now();
        }

        $guest->update($data);

        return response()->json(['guest' => $this->formatGuest($guest->fresh(), detailed: true)]);
    }

    // DELETE /guests/{guest}
    public function destroy(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $guest->delete();
        return response()->json(['message' => 'Guest removed']);
    }

    // POST /guests/{guest}/regenerate-token
    public function regenerateToken(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $guest->update(['token' => Str::random(32)]);
        return response()->json(['token' => $guest->token]);
    }

    // POST /guests/{guest}/check-in
    public function checkIn(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $guest->update(['checked_in_at' => now()]);
        ActivityRecorded::dispatch(
            $guest->wedding_id,
            'check_in',
            trim("{$guest->first_name} {$guest->last_name}"),
            'arrived and checked in',
            now()->toIso8601String(),
        );
        return response()->json(['guest' => $this->formatGuest($guest->fresh())]);
    }

    // POST /guests/{guest}/mark-invited
    public function markInvited(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $fresh = $guest->fresh();
        $guest->update(['invitation_sent_at' => now()]);
        SendGuestInvitation::dispatch($fresh);
        SendGuestSmsInvitation::dispatch($fresh);
        return response()->json(['guest' => $this->formatGuest($guest->fresh())]);
    }

    // POST /guests/bulk-invite
    public function bulkInvite(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'guest_ids' => 'nullable|array',
            'guest_ids.*' => 'string',
            'invite_all_uninvited' => 'boolean',
        ]);

        $query = $wedding->guests();

        if (!empty($data['invite_all_uninvited'])) {
            $query->whereNull('invitation_sent_at');
        } elseif (!empty($data['guest_ids'])) {
            $query->whereIn('id', $data['guest_ids']);
        } else {
            return response()->json(['updated' => 0]);
        }

        // Snapshot before bulk-update so we have the token loaded
        $allGuests      = $query->clone()->get();
        $guestsWithEmail = $allGuests->filter(fn ($g) => !empty($g->email));
        $guestsWithPhone = $allGuests->filter(fn ($g) => !empty($g->phone));

        $updated = $query->update(['invitation_sent_at' => now()]);

        foreach ($guestsWithEmail as $guest) {
            SendGuestInvitation::dispatch($guest);
        }
        foreach ($guestsWithPhone as $guest) {
            SendGuestSmsInvitation::dispatch($guest);
        }

        return response()->json([
            'updated'      => $updated,
            'emails_queued' => $guestsWithEmail->count(),
            'sms_queued'   => $guestsWithPhone->count(),
        ]);
    }

    private function authorizeGuest(Request $request, Guest $guest): void
    {
        $wedding = $this->wedding($request);
        abort_unless($guest->wedding_id === $wedding->id, 403, 'Forbidden');
    }

    private function formatGuest(Guest $g, bool $detailed = false): array
    {
        $base = [
            'id'                  => $g->id,
            'first_name'          => $g->first_name,
            'last_name'           => $g->last_name,
            'full_name'           => $g->full_name,
            'email'               => $g->email,
            'phone'               => $g->phone,
            'rsvp_status'         => $g->rsvp_status,
            'group'               => $g->group,
            'relationship'        => $g->relationship,
            'age_group'           => $g->age_group,
            'is_vip'              => $g->is_vip,
            'dietary_requirements' => $g->dietary_requirements,
            'plus_one_allowed'    => $g->plus_one_allowed,
            'plus_one_name'       => $g->plus_one_name,
            'invitation_sent_at'  => $g->invitation_sent_at?->toIso8601String(),
            'rsvp_responded_at'   => $g->rsvp_responded_at?->toIso8601String(),
            'checked_in_at'       => $g->checked_in_at?->toIso8601String(),
            'needs_transport'     => $g->needs_transport,
            'needs_accommodation' => $g->needs_accommodation,
            'token'               => $g->token,
        ];

        if ($detailed) {
            $base['notes']    = $g->notes;
            $base['address']  = $g->address;
            $base['language'] = $g->language;
        }

        return $base;
    }
}
