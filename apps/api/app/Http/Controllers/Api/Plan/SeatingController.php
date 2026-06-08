<?php

namespace App\Http\Controllers\Api\Plan;

use App\Http\Controllers\Controller;
use App\Models\Guest;
use App\Models\SeatingTable;
use App\Models\TableAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class SeatingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        $tables = SeatingTable::where('wedding_id', $wedding->id)
            ->with(['assignments' => fn ($q) => $q->with('guest:id,first_name,last_name,rsvp_status')])
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get()
            ->map(fn ($t) => $this->formatTable($t));

        $assignedIds = TableAssignment::whereHas(
            'seatingTable',
            fn ($q) => $q->where('wedding_id', $wedding->id)
        )->pluck('guest_id');

        $unassigned = Guest::where('wedding_id', $wedding->id)
            ->where('rsvp_status', 'attending')
            ->whereNotIn('id', $assignedIds)
            ->select('id', 'first_name', 'last_name', 'rsvp_status')
            ->orderBy('first_name')
            ->get();

        $totalAttending = Guest::where('wedding_id', $wedding->id)
            ->where('rsvp_status', 'attending')
            ->count();

        return response()->json([
            'tables'           => $tables,
            'unassigned_guests' => $unassigned,
            'stats'            => [
                'total_attending' => $totalAttending,
                'assigned'        => $totalAttending - $unassigned->count(),
                'unassigned'      => $unassigned->count(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        $data = $request->validate([
            'name'     => 'required|string|max:100',
            'capacity' => 'required|integer|min:1|max:50',
            'shape'    => 'in:round,rectangular,oval',
            'section'  => 'nullable|string|max:100',
            'color'    => 'nullable|string|max:7',
        ]);

        $data['wedding_id'] = $wedding->id;
        $data['sort_order'] = SeatingTable::where('wedding_id', $wedding->id)->max('sort_order') + 1;

        $table = SeatingTable::create($data);
        $table->load('assignments.guest:id,first_name,last_name,rsvp_status');

        return response()->json($this->formatTable($table), 201);
    }

    public function update(Request $request, SeatingTable $table): JsonResponse
    {
        $this->authorizeWedding($request, $table->wedding_id);

        $data = $request->validate([
            'name'       => 'sometimes|string|max:100',
            'capacity'   => 'sometimes|integer|min:1|max:50',
            'shape'      => 'sometimes|in:round,rectangular,oval',
            'section'    => 'nullable|string|max:100',
            'color'      => 'nullable|string|max:7',
            'sort_order' => 'sometimes|integer|min:0',
        ]);

        $table->update($data);
        $table->load('assignments.guest:id,first_name,last_name,rsvp_status');

        return response()->json($this->formatTable($table->fresh()));
    }

    public function destroy(Request $request, SeatingTable $table): Response
    {
        $this->authorizeWedding($request, $table->wedding_id);
        $table->delete();

        return response()->noContent();
    }

    public function assign(Request $request, SeatingTable $table): JsonResponse
    {
        $this->authorizeWedding($request, $table->wedding_id);

        $data = $request->validate([
            'guest_id' => 'required|exists:guests,id',
        ]);

        if ($table->assignments()->count() >= $table->capacity) {
            return response()->json(['message' => 'This table is at full capacity.'], 422);
        }

        // Move guest from any previous table
        TableAssignment::where('guest_id', $data['guest_id'])->delete();

        $table->assignments()->create(['guest_id' => $data['guest_id']]);
        $table->load('assignments.guest:id,first_name,last_name,rsvp_status');

        return response()->json($this->formatTable($table->fresh()));
    }

    public function unassign(Request $request, SeatingTable $table, Guest $guest): Response
    {
        $this->authorizeWedding($request, $table->wedding_id);

        TableAssignment::where('table_id', $table->id)
            ->where('guest_id', $guest->id)
            ->delete();

        return response()->noContent();
    }

    private function formatTable(SeatingTable $table): array
    {
        return [
            'id'         => $table->id,
            'name'       => $table->name,
            'capacity'   => $table->capacity,
            'shape'      => $table->shape,
            'section'    => $table->section,
            'color'      => $table->color,
            'sort_order' => $table->sort_order,
            'assignments' => $table->assignments->map(fn ($a) => [
                'id'                => $a->id,
                'guest_id'          => $a->guest_id,
                'guest_first_name'  => $a->guest?->first_name,
                'guest_last_name'   => $a->guest?->last_name,
                'guest_rsvp_status' => $a->guest?->rsvp_status,
                'seat_number'       => $a->seat_number,
            ]),
        ];
    }

    private function authorizeWedding(Request $request, string $weddingId): void
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $weddingId)->exists(),
            403,
            'Forbidden.'
        );
    }
}
