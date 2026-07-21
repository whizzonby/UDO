<?php

namespace App\Http\Controllers;

use App\Models\SavedFilter;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SavedFilterController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $filters = $this->wedding($request)
            ->savedFilters()
            ->when($request->resource_type, fn ($query) => $query->where('resource_type', $request->resource_type))
            ->orderByDesc('is_default')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $filters]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'resource_type' => 'required|in:guests,tasks,vendors',
            'name' => 'required|string|max:100',
            'criteria' => 'required|array',
            'is_default' => 'nullable|boolean',
        ]);

        if ($data['is_default'] ?? false) {
            $wedding->savedFilters()->where('resource_type', $data['resource_type'])->update(['is_default' => false]);
        }

        $filter = $wedding->savedFilters()->create([
            ...$data,
            'user_id' => $request->user()->id,
            'is_default' => $data['is_default'] ?? false,
        ]);

        return response()->json(['data' => $filter], 201);
    }

    public function update(Request $request, SavedFilter $savedFilter): JsonResponse
    {
        $this->authorizeFilter($request, $savedFilter);

        $data = $request->validate([
            'name' => 'sometimes|string|max:100',
            'criteria' => 'nullable|array',
            'is_default' => 'nullable|boolean',
        ]);

        if (($data['is_default'] ?? false) === true) {
            $this->wedding($request)
                ->savedFilters()
                ->where('resource_type', $savedFilter->resource_type)
                ->whereKeyNot($savedFilter->id)
                ->update(['is_default' => false]);
        }

        $savedFilter->update($data);

        return response()->json(['data' => $savedFilter->fresh()]);
    }

    public function destroy(Request $request, SavedFilter $savedFilter): JsonResponse
    {
        $this->authorizeFilter($request, $savedFilter);
        $savedFilter->delete();

        return response()->json(null, 204);
    }

    private function authorizeFilter(Request $request, SavedFilter $savedFilter): void
    {
        abort_unless($savedFilter->wedding_id === $this->wedding($request)->id, 403);
    }
}
