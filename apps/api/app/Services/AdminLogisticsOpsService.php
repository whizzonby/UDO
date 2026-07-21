<?php

namespace App\Services;

use App\Models\AccommodationOption;
use App\Models\Guest;
use App\Models\GuestTransportAssignment;
use App\Models\TransportGroup;
use App\Models\User;

class AdminLogisticsOpsService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function assignAccommodation(AccommodationOption $accommodation, Guest $guest, User $actor): AccommodationOption
    {
        abort_unless($guest->wedding_id === $accommodation->wedding_id, 403);
        abort_if(
            $accommodation->total_rooms_blocked !== null
            && $accommodation->rooms_assigned >= $accommodation->total_rooms_blocked
            && (int) $guest->hotel_assignment_id !== (int) $accommodation->id,
            422,
            'Accommodation is already fully assigned.'
        );

        $before = ['guest_id' => $guest->id, 'hotel_assignment_id' => $guest->hotel_assignment_id, 'rooms_assigned' => $accommodation->rooms_assigned];
        $guest->forceFill(['hotel_assignment_id' => $accommodation->id])->save();
        $this->refreshAccommodationCount($accommodation);
        $fresh = $accommodation->fresh();

        $this->auditLogService->record(
            'admin.logistics_accommodation_assigned',
            wedding: $fresh->wedding,
            user: $actor,
            auditable: $fresh,
            before: $before,
            after: ['guest_id' => $guest->id, 'hotel_assignment_id' => $fresh->id, 'rooms_assigned' => $fresh->rooms_assigned],
            request: request(),
        );

        return $fresh;
    }

    public function assignTransport(TransportGroup $transport, Guest $guest, User $actor): TransportGroup
    {
        abort_unless($guest->wedding_id === $transport->wedding_id, 403);
        abort_if(
            $transport->capacity !== null
            && $transport->assigned_count >= $transport->capacity
            && (int) $guest->transport_assignment_id !== (int) $transport->id,
            422,
            'Transport group is already at capacity.'
        );

        $before = ['guest_id' => $guest->id, 'transport_assignment_id' => $guest->transport_assignment_id, 'assigned_count' => $transport->assigned_count];
        GuestTransportAssignment::updateOrCreate(
            ['transport_group_id' => $transport->id, 'guest_id' => $guest->id],
            ['wedding_id' => $transport->wedding_id]
        );
        $guest->forceFill(['transport_assignment_id' => $transport->id])->save();
        $this->refreshTransportCount($transport);
        $fresh = $transport->fresh();

        $this->auditLogService->record(
            'admin.logistics_transport_assigned',
            wedding: $fresh->wedding,
            user: $actor,
            auditable: $fresh,
            before: $before,
            after: ['guest_id' => $guest->id, 'transport_assignment_id' => $fresh->id, 'assigned_count' => $fresh->assigned_count],
            request: request(),
        );

        return $fresh;
    }

    private function refreshAccommodationCount(AccommodationOption $accommodation): void
    {
        $accommodation->forceFill([
            'rooms_assigned' => Guest::where('hotel_assignment_id', $accommodation->id)->count(),
        ])->save();
    }

    private function refreshTransportCount(TransportGroup $transport): void
    {
        $transport->forceFill([
            'assigned_count' => GuestTransportAssignment::where('transport_group_id', $transport->id)->count(),
        ])->save();
    }
}
