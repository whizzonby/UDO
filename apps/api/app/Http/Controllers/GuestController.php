<?php

namespace App\Http\Controllers;

use App\Models\Guest;
use App\Models\GuestToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $guests = $wedding->guests()
            ->when($request->group, fn($q) => $q->where('guest_group', $request->group))
            ->when($request->status, fn($q) => $q->where('attending_status', $request->status))
            ->when($request->search, fn($q) => $q->where(function ($q) use ($request) {
                $q->where('first_name', 'like', "%{$request->search}%")
                  ->orWhere('last_name', 'like', "%{$request->search}%")
                  ->orWhere('email', 'like', "%{$request->search}%");
            }))
            ->orderBy('last_name')
            ->orderBy('first_name')
            ->get();

        return response()->json($guests);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'first_name'      => 'required|string|max:100',
            'last_name'       => 'nullable|string|max:100',
            'email'           => 'nullable|email',
            'phone'           => 'nullable|string',
            'guest_group'     => 'nullable|string',
            'vip_flag'        => 'boolean',
            'plus_one_allowed' => 'boolean',
            'meal_preference' => 'nullable|string',
            'allergies'       => 'nullable|string',
            'notes'           => 'nullable|string',
            'wedding_party_role' => 'nullable|string|max:100',
            'attire_status'      => 'nullable|in:not_started,ordered,fitted,ready',
            'rehearsal_status'   => 'nullable|in:pending,confirmed,declined',
        ]);

        $guest = $wedding->guests()->create($data);

        return response()->json($guest, 201);
    }

    public function show(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        return response()->json($guest->load('token'));
    }

    public function update(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        $data = $request->validate([
            'first_name'       => 'sometimes|string|max:100',
            'last_name'        => 'nullable|string|max:100',
            'email'            => 'nullable|email',
            'phone'            => 'nullable|string',
            'guest_group'      => 'nullable|string',
            'custom_tags'      => 'nullable|array',
            'vip_flag'         => 'boolean',
            'attending_status' => 'nullable|in:pending,yes,no',
            'invite_status'    => 'nullable|string',
            'plus_one_allowed' => 'boolean',
            'plus_one_count'   => 'integer|min:0|max:5',
            'meal_preference'  => 'nullable|string',
            'allergies'        => 'nullable|string',
            'dietary_note'     => 'nullable|string',
            'travel_required'  => 'boolean',
            'arrival_date'     => 'nullable|date',
            'departure_date'   => 'nullable|date',
            'arrival_airport'  => 'nullable|string',
            'notes'            => 'nullable|string',
            'wedding_party_role' => 'nullable|string|max:100',
            'attire_status'      => 'nullable|in:not_started,ordered,fitted,ready',
            'rehearsal_status'   => 'nullable|in:pending,confirmed,declined',
        ]);

        $guest->update($data);

        return response()->json($guest->fresh());
    }

    public function destroy(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);
        $guest->delete();

        return response()->json(null, 204);
    }

    public function generateToken(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        $existing = $guest->token;
        if ($existing) {
            $existing->update(['revoked' => false]);
            return response()->json(['token' => $existing->token]);
        }

        $guestToken = GuestToken::create([
            'wedding_id' => $guest->wedding_id,
            'guest_id'   => $guest->id,
            'view_type'  => $guest->guest_view_type,
        ]);

        return response()->json(['token' => $guestToken->token]);
    }

    public function sendInvite(Request $request, Guest $guest): JsonResponse
    {
        $this->authorizeGuest($request, $guest);

        // Ensure token exists
        if (! $guest->token) {
            GuestToken::create([
                'wedding_id' => $guest->wedding_id,
                'guest_id'   => $guest->id,
                'view_type'  => $guest->guest_view_type,
            ]);
            $guest->load('token');
        }

        // TODO: dispatch SendGuestInviteJob with email/SMS
        $guest->update(['invite_status' => 'sent']);

        return response()->json(['message' => 'Invite queued.']);
    }

    public function bulkImport(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $request->validate([
            'guests'              => 'required|array|min:1',
            'guests.*.first_name' => 'required|string',
            'guests.*.last_name'  => 'nullable|string',
            'guests.*.email'      => 'nullable|email',
        ]);

        $created = collect($request->guests)->map(fn($g) => $wedding->guests()->create($g));

        return response()->json(['imported' => $created->count()]);
    }

    private function authorizeGuest(Request $request, Guest $guest): void
    {
        $wedding = $this->wedding($request);
        abort_unless($guest->wedding_id === $wedding->id, 403, 'Forbidden.');
    }
}
