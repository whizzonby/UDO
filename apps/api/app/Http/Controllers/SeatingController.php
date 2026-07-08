<?php

namespace App\Http\Controllers;

use App\Models\SeatingTable;
use App\Models\SeatingSeat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SeatingController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
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
            $table->seats()->create(['seat_number' => $i]);
        }

        return response()->json(['data' => $table->load('seats')], 201);
    }

    public function updateTable(Request $request, SeatingTable $seatingTable): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);

        $data = $request->validate([
            'name'          => 'sometimes|string|max:100',
            'shape'         => 'nullable|in:round,rectangle,oval,square',
            'pos_x'         => 'nullable|numeric',
            'pos_y'         => 'nullable|numeric',
            'event_section' => 'nullable|string|max:100',
            'notes'         => 'nullable|string',
        ]);

        $seatingTable->update($data);

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

        $seat = $seatingTable->seats()->where('seat_number', $data['seat_number'])->firstOrFail();

        // Remove guest from any other seat first
        if ($data['guest_id']) {
            SeatingSeat::where('guest_id', $data['guest_id'])->update(['guest_id' => null]);
        }

        $seat->update(['guest_id' => $data['guest_id']]);

        return response()->json(['data' => $seat->load('guest')]);
    }

    public function clearSeat(Request $request, SeatingTable $seatingTable, SeatingSeat $seatingSeat): JsonResponse
    {
        $this->authorizeTable($request, $seatingTable);
        abort_unless($seatingSeat->seating_table_id === $seatingTable->id, 403);
        $seatingSeat->update(['guest_id' => null]);
        return response()->json(['data' => $seatingSeat]);
    }

    private function authorizeTable(Request $request, SeatingTable $seatingTable): void
    {
        abort_unless($seatingTable->wedding_id === $this->wedding($request)->id, 403);
    }
}
