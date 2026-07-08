<?php

namespace App\Http\Controllers;

use App\Models\GuestToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestPortalController extends Controller
{
    public function show(string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with(['guest', 'wedding'])->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');

        $guest   = $guestToken->guest;
        $wedding = $guestToken->wedding;

        return response()->json([
            'view_type' => $guestToken->view_type,
            'guest'     => [
                'id'               => $guest->id,
                'first_name'       => $guest->first_name,
                'last_name'        => $guest->last_name,
                'attending_status' => $guest->attending_status,
                'plus_one_allowed' => $guest->plus_one_allowed,
                'plus_one_count'   => $guest->plus_one_count,
                'meal_preference'  => $guest->meal_preference,
                'travel_required'  => $guest->travel_required,
                'arrival_date'     => $guest->arrival_date?->toDateString(),
                'departure_date'   => $guest->departure_date?->toDateString(),
            ],
            'wedding' => [
                'title'                => $wedding->title,
                'couple_name_primary'  => $wedding->couple_name_primary,
                'couple_name_secondary' => $wedding->couple_name_secondary,
                'event_date'           => $wedding->event_date?->toDateString(),
                'city'                 => $wedding->city,
                'country'              => $wedding->country,
                'venue'                => $wedding->primary_venue_name,
                'venue_address'        => $wedding->primary_venue_address,
                'rsvp_deadline'        => $wedding->rsvp_deadline?->toDateString(),
            ],
        ]);
    }

    public function rsvp(Request $request, string $token): JsonResponse
    {
        $guestToken = GuestToken::where('token', $token)->with('guest')->firstOrFail();

        abort_unless($guestToken->isValid(), 403, 'This invitation link is no longer valid.');

        $data = $request->validate([
            'attending_status' => 'required|in:yes,no',
            'plus_one_count'   => 'nullable|integer|min:0|max:5',
            'meal_preference'  => 'nullable|string',
            'dietary_note'     => 'nullable|string',
        ]);

        $guest = $guestToken->guest;

        $update = ['attending_status' => $data['attending_status']];

        if (isset($data['plus_one_count']) && $guest->plus_one_allowed) {
            $update['plus_one_count'] = $data['plus_one_count'];
        }

        if (isset($data['meal_preference'])) {
            $update['meal_preference'] = $data['meal_preference'];
        }

        if (isset($data['dietary_note'])) {
            $update['dietary_note'] = $data['dietary_note'];
        }

        $guest->update($update);

        return response()->json(['message' => 'RSVP saved.', 'status' => $data['attending_status']]);
    }
}
