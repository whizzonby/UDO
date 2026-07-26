<?php

namespace App\Http\Controllers;

use App\Models\AccommodationOption;
use App\Models\Guest;
use App\Models\TransportGroup;
use App\Models\GuestTransportAssignment;
use App\Services\AuditLogService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LogisticsController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_guests'), 403);
        return $wedding;
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $guests = $wedding->guests()->get();
        $travelling = $guests->where('travel_required', true);
        $missingArrival = $travelling->filter(fn (Guest $guest) => ! $guest->arrival_date || ! $guest->arrival_time)->values();
        $missingDeparture = $travelling->filter(fn (Guest $guest) => ! $guest->departure_date || ! $guest->departure_time)->values();
        $missingAccommodation = $travelling->filter(fn (Guest $guest) => ! $guest->hotel_assignment_id)->values();
        $missingTransport = $travelling->filter(fn (Guest $guest) => ! $guest->transport_assignment_id)->values();
        $transportCapacity = (int) $wedding->transportGroups()->sum('capacity');
        $transportAssigned = (int) $wedding->transportGroups()->sum('assigned_count');

        return response()->json([
            'data' => [
                'travelling_guests' => $travelling->count(),
                'arrival_complete' => $travelling->count() - $missingArrival->count(),
                'departure_complete' => $travelling->count() - $missingDeparture->count(),
                'accommodation_assigned' => $travelling->count() - $missingAccommodation->count(),
                'transport_assigned' => $travelling->count() - $missingTransport->count(),
                'missing_arrival_info' => $missingArrival->count(),
                'missing_departure_info' => $missingDeparture->count(),
                'missing_accommodation' => $missingAccommodation->count(),
                'missing_transport' => $missingTransport->count(),
                'transport_capacity' => $transportCapacity,
                'transport_seats_remaining' => max(0, $transportCapacity - $transportAssigned),
                'accommodation_options' => $wedding->accommodationOptions()->count(),
                'transport_groups' => $wedding->transportGroups()->count(),
                'incomplete_guests' => $travelling
                    ->filter(fn (Guest $guest) => ! $guest->arrival_date || ! $guest->arrival_time || ! $guest->hotel_assignment_id || ! $guest->transport_assignment_id)
                    ->map(fn (Guest $guest) => [
                        'id' => $guest->id,
                        'name' => $guest->full_name,
                        'missing' => array_values(array_filter([
                            ! $guest->arrival_date || ! $guest->arrival_time ? 'arrival' : null,
                            ! $guest->departure_date || ! $guest->departure_time ? 'departure' : null,
                            ! $guest->hotel_assignment_id ? 'accommodation' : null,
                            ! $guest->transport_assignment_id ? 'transport' : null,
                        ])),
                    ])
                    ->values()
                    ->all(),
            ],
        ]);
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

    public function assignAccommodation(Request $request, AccommodationOption $accommodationOption): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($accommodationOption->wedding_id === $wedding->id, 403);

        $data = $request->validate([
            'guest_id' => 'required|integer|exists:guests,id',
        ]);

        $guest = Guest::findOrFail($data['guest_id']);
        abort_unless($guest->wedding_id === $accommodationOption->wedding_id, 403);
        abort_if(
            $accommodationOption->total_rooms_blocked !== null
            && $accommodationOption->rooms_assigned >= $accommodationOption->total_rooms_blocked
            && (int) $guest->hotel_assignment_id !== (int) $accommodationOption->id,
            422,
            'Accommodation is already fully assigned.'
        );

        $guest->update(['hotel_assignment_id' => $accommodationOption->id]);
        $this->refreshAccommodationCount($accommodationOption);
        app(AuditLogService::class)->record('guest.hotel_assigned', $wedding, $request->user(), $guest->fresh(), null, ['hotel_assignment_id' => $accommodationOption->id, 'hotel_name' => $accommodationOption->name], request: $request);

        return response()->json(['data' => $accommodationOption->fresh()]);
    }

    public function removeAccommodation(Request $request, AccommodationOption $accommodationOption, int $guestId): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($accommodationOption->wedding_id === $wedding->id, 403);

        $guest = Guest::find($guestId);
        Guest::query()
            ->where('wedding_id', $accommodationOption->wedding_id)
            ->where('id', $guestId)
            ->where('hotel_assignment_id', $accommodationOption->id)
            ->update(['hotel_assignment_id' => null]);

        $this->refreshAccommodationCount($accommodationOption);
        if ($guest) {
            app(AuditLogService::class)->record('guest.hotel_unassigned', $wedding, $request->user(), $guest, ['hotel_assignment_id' => $accommodationOption->id], null, request: $request);
        }

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
            'type'           => 'nullable|string|max:100',
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
            'type'           => 'nullable|string|max:100',
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
        $wedding = $this->wedding($request);
        abort_unless($transportGroup->wedding_id === $wedding->id, 403);

        $data = $request->validate([
            'guest_id' => 'required|integer|exists:guests,id',
        ]);
        $guest = Guest::findOrFail($data['guest_id']);
        abort_unless($guest->wedding_id === $transportGroup->wedding_id, 403);
        abort_if(
            $transportGroup->capacity !== null
            && $transportGroup->assigned_count >= $transportGroup->capacity
            && (int) $guest->transport_assignment_id !== (int) $transportGroup->id,
            422,
            'Transport group is already at capacity.'
        );

        GuestTransportAssignment::updateOrCreate(
            ['transport_group_id' => $transportGroup->id, 'guest_id' => $data['guest_id']],
            ['wedding_id' => $transportGroup->wedding_id]
        );
        $guest->update(['transport_assignment_id' => $transportGroup->id]);
        $this->refreshTransportCount($transportGroup);
        app(AuditLogService::class)->record('guest.transport_assigned', $wedding, $request->user(), $guest->fresh(), null, ['transport_assignment_id' => $transportGroup->id, 'transport_name' => $transportGroup->name], request: $request);

        return response()->json(['data' => $transportGroup->fresh()->load('assignments.guest')]);
    }

    public function removeTransport(Request $request, TransportGroup $transportGroup, int $guestId): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($transportGroup->wedding_id === $wedding->id, 403);

        GuestTransportAssignment::where([
            'transport_group_id' => $transportGroup->id,
            'guest_id'           => $guestId,
        ])->delete();
        $guest = Guest::find($guestId);
        Guest::query()
            ->where('wedding_id', $transportGroup->wedding_id)
            ->where('id', $guestId)
            ->where('transport_assignment_id', $transportGroup->id)
            ->update(['transport_assignment_id' => null]);
        $this->refreshTransportCount($transportGroup);
        if ($guest) {
            app(AuditLogService::class)->record('guest.transport_unassigned', $wedding, $request->user(), $guest, ['transport_assignment_id' => $transportGroup->id], null, request: $request);
        }

        return response()->json(null, 204);
    }

    private function refreshAccommodationCount(AccommodationOption $accommodationOption): void
    {
        $accommodationOption->update([
            'rooms_assigned' => Guest::where('hotel_assignment_id', $accommodationOption->id)->count(),
        ]);
    }

    private function refreshTransportCount(TransportGroup $transportGroup): void
    {
        $transportGroup->update([
            'assigned_count' => GuestTransportAssignment::where('transport_group_id', $transportGroup->id)->count(),
        ]);
    }
}
