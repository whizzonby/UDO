<?php

namespace App\Http\Controllers;

use App\Models\AccommodationOption;
use App\Models\TransportGroup;
use App\Models\GuestTransportAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogisticsController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    // ── Accommodation ──────────────────────────────────────────────────────────

    public function accommodations(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->wedding($request)->accommodationOptions()->get()]);
    }

    public function storeAccommodation(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'              => 'required|string|max:255',
            'type'              => 'nullable|in:hotel,airbnb,guest_house,other',
            'address'           => 'nullable|string',
            'distance_km'       => 'nullable|numeric|min:0',
            'price_per_night'   => 'nullable|numeric|min:0',
            'total_rooms'       => 'nullable|integer|min:0',
            'rooms_available'   => 'nullable|integer|min:0',
            'booking_url'       => 'nullable|url',
            'booking_code'      => 'nullable|string|max:100',
            'contact_name'      => 'nullable|string|max:255',
            'contact_phone'     => 'nullable|string|max:50',
            'contact_email'     => 'nullable|email',
            'check_in_date'     => 'nullable|date',
            'check_out_date'    => 'nullable|date|after_or_equal:check_in_date',
            'notes'             => 'nullable|string',
        ]);

        $accommodation = $wedding->accommodationOptions()->create($this->mapAccommodationFields($data));
        return response()->json(['data' => $accommodation], 201);
    }

    public function updateAccommodation(Request $request, AccommodationOption $accommodationOption): JsonResponse
    {
        abort_unless($accommodationOption->wedding_id === $this->wedding($request)->id, 403);

        $data = $request->validate([
            'name'              => 'sometimes|string|max:255',
            'type'              => 'nullable|in:hotel,airbnb,guest_house,other',
            'address'           => 'nullable|string',
            'distance_km'       => 'nullable|numeric|min:0',
            'price_per_night'   => 'nullable|numeric|min:0',
            'total_rooms'       => 'nullable|integer|min:0',
            'rooms_available'   => 'nullable|integer|min:0',
            'booking_url'       => 'nullable|url',
            'booking_code'      => 'nullable|string|max:100',
            'contact_name'      => 'nullable|string|max:255',
            'contact_phone'     => 'nullable|string|max:50',
            'contact_email'     => 'nullable|email',
            'check_in_date'     => 'nullable|date',
            'check_out_date'    => 'nullable|date',
            'notes'             => 'nullable|string',
        ]);

        $accommodationOption->update($this->mapAccommodationFields($data));
        return response()->json(['data' => $accommodationOption->fresh()]);
    }

    /**
     * The accommodation form uses field names that don't match the model's
     * columns 1:1 (e.g. `total_rooms` vs `total_rooms_blocked`) — remap them
     * here rather than changing the API contract the mobile app already sends.
     */
    private function mapAccommodationFields(array $data): array
    {
        $renames = [
            'distance_km'     => 'distance_from_venue_km',
            'total_rooms'     => 'total_rooms_blocked',
            'rooms_available' => 'rooms_assigned',
            'booking_url'     => 'website',
        ];

        foreach ($renames as $from => $to) {
            if (array_key_exists($from, $data)) {
                $data[$to] = $data[$from];
                unset($data[$from]);
            }
        }

        return $data;
    }

    public function destroyAccommodation(Request $request, AccommodationOption $accommodationOption): JsonResponse
    {
        abort_unless($accommodationOption->wedding_id === $this->wedding($request)->id, 403);
        $accommodationOption->delete();
        return response()->json(null, 204);
    }

    // ── Transport ──────────────────────────────────────────────────────────────

    public function transportGroups(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->wedding($request)->transportGroups()->with('assignments.guest')->get(),
        ]);
    }

    public function storeTransportGroup(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'           => 'required|string|max:255',
            'vehicle_type'   => 'nullable|string|max:100',
            'capacity'       => 'nullable|integer|min:1',
            'departure_time' => 'nullable|date',
            'pickup_location' => 'nullable|string|max:255',
            'dropoff_location' => 'nullable|string|max:255',
            'driver_name'    => 'nullable|string|max:255',
            'driver_phone'   => 'nullable|string|max:50',
            'notes'          => 'nullable|string',
        ]);

        $group = $wedding->transportGroups()->create($data);
        return response()->json(['data' => $group], 201);
    }

    public function updateTransportGroup(Request $request, TransportGroup $transportGroup): JsonResponse
    {
        abort_unless($transportGroup->wedding_id === $this->wedding($request)->id, 403);

        $data = $request->validate([
            'name'           => 'sometimes|string|max:255',
            'vehicle_type'   => 'nullable|string|max:100',
            'capacity'       => 'nullable|integer|min:1',
            'departure_time' => 'nullable|date',
            'pickup_location' => 'nullable|string|max:255',
            'dropoff_location' => 'nullable|string|max:255',
            'driver_name'    => 'nullable|string|max:255',
            'driver_phone'   => 'nullable|string|max:50',
            'notes'          => 'nullable|string',
        ]);

        $transportGroup->update($data);
        return response()->json(['data' => $transportGroup->fresh()]);
    }

    public function destroyTransportGroup(Request $request, TransportGroup $transportGroup): JsonResponse
    {
        abort_unless($transportGroup->wedding_id === $this->wedding($request)->id, 403);
        $transportGroup->delete();
        return response()->json(null, 204);
    }

    public function assignTransport(Request $request, TransportGroup $transportGroup): JsonResponse
    {
        abort_unless($transportGroup->wedding_id === $this->wedding($request)->id, 403);

        $data = $request->validate([
            'guest_id' => 'required|integer|exists:guests,id',
        ]);

        GuestTransportAssignment::updateOrCreate(
            ['transport_group_id' => $transportGroup->id, 'guest_id' => $data['guest_id']],
            []
        );

        return response()->json(['data' => $transportGroup->load('assignments.guest')]);
    }

    public function removeTransport(Request $request, TransportGroup $transportGroup, int $guestId): JsonResponse
    {
        abort_unless($transportGroup->wedding_id === $this->wedding($request)->id, 403);

        GuestTransportAssignment::where([
            'transport_group_id' => $transportGroup->id,
            'guest_id'           => $guestId,
        ])->delete();

        return response()->json(null, 204);
    }
}
