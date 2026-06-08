<?php

namespace App\Http\Controllers\Api\Registry;

use App\Http\Controllers\Controller;
use App\Models\RegistryItem;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegistryController extends Controller
{
    private function wedding(Request $request): Wedding
    {
        return $request->user()->weddings()->latest('wedding_users.created_at')->firstOrFail();
    }

    // GET /registry
    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $items   = $wedding->registryItems()->get();
        $fund    = $wedding->registryCashFund;

        $claimed      = $items->where('is_claimed', true);
        $unclaimed    = $items->where('is_claimed', false);
        $thanksPending = $claimed->where('thank_you_sent', false);

        return response()->json([
            'items' => $items->map(fn ($i) => $this->formatItem($i)),
            'fund'  => $fund ? $this->formatFund($fund) : null,
            'summary' => [
                'total_items'       => $items->count(),
                'claimed'           => $claimed->count(),
                'unclaimed'         => $unclaimed->count(),
                'thank_yous_pending'=> $thanksPending->count(),
                'total_value'       => (float) $items->sum('price'),
                'claimed_value'     => (float) $claimed->sum('price'),
            ],
        ]);
    }

    // POST /registry/items
    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'title'       => 'required|string|max:200',
            'description' => 'nullable|string|max:1000',
            'price'       => 'nullable|numeric|min:0',
            'url'         => 'nullable|url|max:500',
            'image_url'   => 'nullable|url|max:500',
            'category'    => 'nullable|string|max:100',
        ]);

        $item = $wedding->registryItems()->create($data);

        return response()->json(['item' => $this->formatItem($item)], 201);
    }

    // PUT /registry/items/{item}
    public function update(Request $request, RegistryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);

        $data = $request->validate([
            'title'       => 'sometimes|string|max:200',
            'description' => 'nullable|string|max:1000',
            'price'       => 'nullable|numeric|min:0',
            'url'         => 'nullable|url|max:500',
            'image_url'   => 'nullable|url|max:500',
            'category'    => 'nullable|string|max:100',
        ]);

        $item->update($data);

        return response()->json(['item' => $this->formatItem($item->fresh())]);
    }

    // DELETE /registry/items/{item}
    public function destroy(Request $request, RegistryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->delete();
        return response()->json(['message' => 'Deleted']);
    }

    // PATCH /registry/items/{item}/claim
    public function claim(Request $request, RegistryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);

        $data = $request->validate([
            'claimed_by_name' => 'nullable|string|max:200',
        ]);

        $item->update([
            'is_claimed'      => true,
            'claimed_by_name' => $data['claimed_by_name'] ?? null,
        ]);

        return response()->json(['item' => $this->formatItem($item->fresh())]);
    }

    // PATCH /registry/items/{item}/unclaim
    public function unclaim(Request $request, RegistryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->update(['is_claimed' => false, 'claimed_by_name' => null, 'thank_you_sent' => false]);
        return response()->json(['item' => $this->formatItem($item->fresh())]);
    }

    // PATCH /registry/items/{item}/thank
    public function markThanked(Request $request, RegistryItem $item): JsonResponse
    {
        $this->authorizeItem($request, $item);
        $item->update(['thank_you_sent' => true]);
        return response()->json(['item' => $this->formatItem($item->fresh())]);
    }

    // GET /registry/fund
    public function getFund(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $fund = $wedding->registryCashFund ?? $this->createDefaultFund($wedding->id);
        return response()->json(['fund' => $this->formatFund($fund)]);
    }

    // PUT /registry/fund
    public function updateFund(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'title'         => 'nullable|string|max:200',
            'description'   => 'nullable|string|max:1000',
            'target_amount' => 'nullable|numeric|min:0',
            'is_active'     => 'boolean',
        ]);

        $fund = $wedding->registryCashFund ?? $this->createDefaultFund($wedding->id);
        $fund->update($data);

        return response()->json(['fund' => $this->formatFund($fund->fresh())]);
    }

    private function createDefaultFund(string $weddingId): \App\Models\RegistryCashFund
    {
        return \App\Models\RegistryCashFund::create(['wedding_id' => $weddingId]);
    }

    private function authorizeItem(Request $request, RegistryItem $item): void
    {
        abort_unless($item->wedding_id === $this->wedding($request)->id, 403);
    }

    private function formatItem(RegistryItem $i): array
    {
        return [
            'id'              => $i->id,
            'title'           => $i->title,
            'description'     => $i->description,
            'price'           => $i->price ? (float) $i->price : null,
            'url'             => $i->url,
            'image_url'       => $i->image_url,
            'category'        => $i->category,
            'is_claimed'      => $i->is_claimed,
            'claimed_by_name' => $i->claimed_by_name,
            'thank_you_sent'  => $i->thank_you_sent,
            'sort_order'      => $i->sort_order,
        ];
    }

    private function formatFund(\App\Models\RegistryCashFund $f): array
    {
        return [
            'id'            => $f->id,
            'title'         => $f->title,
            'description'   => $f->description,
            'target_amount' => $f->target_amount ? (float) $f->target_amount : null,
            'is_active'     => $f->is_active,
            'share_token'   => $f->share_token,
        ];
    }
}
