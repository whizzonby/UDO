<?php

namespace App\Http\Controllers;

use App\Models\RegistryItem;
use App\Models\RegistryContribution;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegistryController extends Controller
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
            ->registryItems()
            ->withCount('contributions')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'               => 'required|string|max:255',
            'type'               => 'nullable|in:item,cash_fund,experience',
            'description'        => 'nullable|string',
            'price'              => 'nullable|numeric|min:0',
            'quantity_requested' => 'nullable|integer|min:1',
            'fund_goal'          => 'nullable|numeric|min:0',
            'image_url'          => 'nullable|url',
            'store_url'          => 'nullable|url',
            'store_name'         => 'nullable|string|max:255',
            'stripe_payment_link' => 'nullable|url',
            'sort_order'         => 'nullable|integer',
        ]);

        $item = $wedding->registryItems()->create($data);

        return response()->json(['data' => $item], 201);
    }

    public function show(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        return response()->json(['data' => $registryItem->load('contributions.guest')]);
    }

    public function update(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);

        $data = $request->validate([
            'name'               => 'sometimes|string|max:255',
            'type'               => 'nullable|in:item,cash_fund,experience',
            'description'        => 'nullable|string',
            'price'              => 'nullable|numeric|min:0',
            'quantity_requested' => 'nullable|integer|min:1',
            'fund_goal'          => 'nullable|numeric|min:0',
            'image_url'          => 'nullable|url',
            'store_url'          => 'nullable|url',
            'store_name'         => 'nullable|string|max:255',
            'sort_order'         => 'nullable|integer',
        ]);

        $registryItem->update($data);

        return response()->json(['data' => $registryItem->fresh()]);
    }

    public function destroy(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        $registryItem->delete();
        return response()->json(null, 204);
    }

    public function contributions(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        return response()->json(['data' => $registryItem->contributions()->with('guest')->get()]);
    }

    private function authorizeItem(Request $request, RegistryItem $registryItem): void
    {
        abort_unless($registryItem->wedding_id === $this->wedding($request)->id, 403);
    }
}
