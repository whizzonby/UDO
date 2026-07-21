<?php

namespace App\Http\Controllers;

use App\Models\Guest;
use App\Models\SeatingTable;
use App\Models\SeatingSeat;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SeatingController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_plan'), 403);
        return $wedding;
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $tables = $wedding->seatingTables()->with('seats.guest')->get();
        $attendingGuests = $wedding->guests()->where('attending_status', 'yes')->get();
        $assignedGuestIds = SeatingSeat::query()
            ->where('wedding_id', $wedding->id)
            ->whereNotNull('guest_id')
            ->pluck('guest_id')
            ->unique();
        $unassignedAttendingGuests = $attendingGuests->whereNotIn('id', $assignedGuestIds->all());

        return response()->json([
            'data' => [
                'table_count' => $tables->count(),
                'seat_count' => $tables->sum('capacity'),
                'assigned_count' => $assignedGuestIds->count(),
                'attending_guest_count' => $attendingGuests->count(),
                'unassigned_attending_count' => $unassignedAttendingGuests->count(),
                'open_seats' => max(0, $tables->sum('capacity') - $assignedGuestIds->count()),
                'tables_over_capacity' => $tables
                    ->filter(fn (SeatingTable $table) => $table->assigned_count > $table->capacity)
                    ->map(fn (SeatingTable $table) => [
                        'id' => $table->id,
                        'name' => $table->name,
                        'capacity' => $table->capacity,
                        'assigned_count' => $table->assigned_count,
                    ])
                    ->values()
                    ->all(),
                'unassigned_guests' => $unassignedAttendingGuests
                    ->map(fn (Guest $guest) => [
                        'id' => $guest->id,
                        'name' => $guest->full_name,
                        'guest_group' => $guest->guest_group,
                        'vip_flag' => $guest->vip_flag,
                    ])
                    ->values()
                    ->all(),
            ],
        ]);
    }

    public function index(Request $request): JsonResponse
    {
        $tables = $this->wedding($request)
            ->seatingTables()
            ->with(['seats.guest'])
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $tables]);
    }

    public function storeTable(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'          => 'required|string|max:100',
            'shape'         => 'nullable|in:round,rectangle,oval,square',
            'capacity'      => 'required|integer|min:1|max:50',
            'pos_x'         => 'nullable|numeric',
            'pos_y'         => 'nullable|numeric',
            'event_section' => 'nullable|string|max:100',
            'notes'         => 'nullable|string',
        ]);

        $table = $wedding->seatingTables()->create($data);

        // Auto-create empty seats
        for ($i = 1; $i <= $data['capacity']; $i++) {
            $table->seats()->create(['wedding_id' => $wedding->id, 'seat_number' => $i]);
        }

        return response()->json(['data' => $table->load('seats')], 201);
    }

    public function updateTable(Request $request, SeatingTable $seatingTable): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);

        $data = $request->validate([
            'name'          => 'sometimes|string|max:100',
            'shape'         => 'nullable|in:round,rectangle,oval,square',
            'capacity'      => 'nullable|integer|min:1|max:50',
            'pos_x'         => 'nullable|numeric',
            'pos_y'         => 'nullable|numeric',
            'event_section' => 'nullable|string|max:100',
            'notes'         => 'nullable|string',
        ]);

        $seatingTable->update($data);
        if (array_key_exists('capacity', $data)) {
            $this->syncSeatsToCapacity($seatingTable->fresh(), (int) $data['capacity']);
        }
        $this->refreshAssignedCount($seatingTable);

        return response()->json(['data' => $seatingTable->fresh()->load('seats.guest')]);
    }

    public function destroyTable(Request $request, SeatingTable $seatingTable): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);
        $seatingTable->delete();
        return response()->json(null, 204);
    }

    public function assignSeat(Request $request, SeatingTable $seatingTable): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);

        $data = $request->validate([
            'seat_number' => 'required|integer|min:1',
            'guest_id'    => 'nullable|integer|exists:guests,id',
        ]);
        $guestId = $data['guest_id'] ?? null;

        $seat = $seatingTable->seats()->where('seat_number', $data['seat_number'])->firstOrFail();
        $previousGuestId = $seat->guest_id;

        // Remove guest from any other seat first
        if ($guestId) {
            $guest = Guest::findOrFail($guestId);
            abort_unless($guest->wedding_id === $seatingTable->wedding_id, 403);
            SeatingSeat::where('wedding_id', $seatingTable->wedding_id)
                ->where('guest_id', $guest->id)
                ->update(['guest_id' => null]);
            Guest::where('wedding_id', $seatingTable->wedding_id)
                ->where('seating_assignment_id', $seat->id)
                ->update(['seating_assignment_id' => null]);
        }

        if ($previousGuestId) {
            Guest::where('id', $previousGuestId)->update(['seating_assignment_id' => null]);
        }
        $seat->update(['guest_id' => $guestId]);
        if ($guestId) {
            Guest::where('id', $guestId)->update(['seating_assignment_id' => $seat->id]);
        }
        $this->refreshAllAssignedCounts($seatingTable->wedding_id);

        return response()->json(['data' => $seat->load('guest')]);
    }

    public function clearSeat(Request $request, SeatingTable $seatingTable, SeatingSeat $seatingSeat): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);
        abort_unless($seatingSeat->seating_table_id === $seatingTable->id, 403);
        if ($seatingSeat->guest_id) {
            Guest::where('id', $seatingSeat->guest_id)->update(['seating_assignment_id' => null]);
        }
        $seatingSeat->update(['guest_id' => null]);
        $this->refreshAllAssignedCounts($seatingTable->wedding_id);
        return response()->json(['data' => $seatingSeat]);
    }

    private function authorizeTable(Request $request, SeatingTable $seatingTable): void
    {
        abort_unless($seatingTable->wedding_id === $this->wedding($request)->id, 403);
    }

    private function syncSeatsToCapacity(SeatingTable $table, int $capacity): void
    {
        $currentCount = $table->seats()->count();

        if ($capacity > $currentCount) {
            for ($seatNumber = $currentCount + 1; $seatNumber <= $capacity; $seatNumber++) {
                $table->seats()->create([
                    'wedding_id' => $table->wedding_id,
                    'seat_number' => $seatNumber,
                ]);
            }
        }

        if ($capacity < $currentCount) {
            $removable = $table->seats()
                ->where('seat_number', '>', $capacity)
                ->whereNull('guest_id')
                ->orderByDesc('seat_number')
                ->limit($currentCount - $capacity)
                ->get();

            abort_if($removable->count() < ($currentCount - $capacity), 422, 'Cannot reduce capacity below occupied seats.');
            $removable->each->delete();
        }
    }

    private function refreshAssignedCount(SeatingTable $table): void
    {
        $table->update([
            'assigned_count' => $table->seats()->whereNotNull('guest_id')->count(),
        ]);
    }

    private function refreshAllAssignedCounts(int $weddingId): void
    {
        SeatingTable::where('wedding_id', $weddingId)
            ->get()
            ->each(fn (SeatingTable $table) => $this->refreshAssignedCount($table));
    }
}
