<?php

namespace App\Http\Controllers\WeddingParty;

use App\Http\Controllers\Controller;
use App\Models\WeddingPartyResponsibility;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ResponsibilityController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)
            ->weddingPartyResponsibilities()
            ->with('guest:id,first_name,last_name')
            ->get();

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'guest_id'    => 'nullable|integer|exists:guests,id',
            'title'       => 'required|string|max:255',
            'description' => 'nullable|string',
            'status'      => 'nullable|in:pending,in_progress,done',
            'due_date'    => 'nullable|date',
            'sort_order'  => 'nullable|integer',
        ]);

        $item = $wedding->weddingPartyResponsibilities()->create($data);

        return response()->json(['data' => $item->load('guest:id,first_name,last_name')], 201);
    }

    public function update(Request $request, WeddingPartyResponsibility $responsibility): JsonResponse
    {
        $this->authorize($request, $responsibility);

        $data = $request->validate([
            'guest_id'    => 'nullable|integer|exists:guests,id',
            'title'       => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'status'      => 'nullable|in:pending,in_progress,done',
            'due_date'    => 'nullable|date',
            'sort_order'  => 'nullable|integer',
        ]);

        $responsibility->update($data);

        return response()->json(['data' => $responsibility->fresh()->load('guest:id,first_name,last_name')]);
    }

    public function destroy(Request $request, WeddingPartyResponsibility $responsibility): JsonResponse
    {
        $this->authorize($request, $responsibility);
        $responsibility->delete();
        return response()->json(null, 204);
    }

    private function authorize(Request $request, WeddingPartyResponsibility $responsibility): void
    {
        abort_unless($responsibility->wedding_id === $this->wedding($request)->id, 403);
    }
}
