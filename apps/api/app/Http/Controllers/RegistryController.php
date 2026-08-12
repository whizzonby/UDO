<?php

namespace App\Http\Controllers;

use App\Models\RegistryItem;
use App\Models\RegistryContribution;
use App\Models\ThankYouRecord;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegistryController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManageRegistry(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_registry'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)
            ->registryItems()
            ->withCount('contributions')
            ->withSum(['contributions as contributions_total' => fn ($query) => $query->where('payment_status', 'completed')], 'amount')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $items]);
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $items = $wedding->registryItems()->with('contributions')->get();
        $contributions = RegistryContribution::query()
            ->where('wedding_id', $wedding->id)
            ->with(['item', 'guest'])
            ->latest()
            ->get();
        $pendingThanks = ThankYouRecord::query()
            ->where('wedding_id', $wedding->id)
            ->whereIn('status', ['pending', 'draft'])
            ->with(['contribution.item', 'guest'])
            ->latest()
            ->get();
        $sentThanks = ThankYouRecord::query()
            ->where('wedding_id', $wedding->id)
            ->whereIn('status', ['sent', 'done'])
            ->with(['contribution.item', 'guest'])
            ->latest('sent_at')
            ->get();

        return response()->json(['data' => [
            'item_count' => $items->count(),
            'visible_item_count' => $items->where('is_visible', true)->count(),
            'contribution_count' => $contributions->where('payment_status', 'completed')->count(),
            'total_contributed' => (float) $contributions->where('payment_status', 'completed')->sum('amount'),
            'fund_goal_total' => (float) $items->sum('fund_goal'),
            'fund_raised_total' => (float) $items->sum('fund_raised'),
            'pending_thank_yous' => $pendingThanks->count(),
            'sent_thank_yous' => $sentThanks->count(),
            'recent_contributions' => $contributions->take(8)->values(),
            'thank_yous' => [
                'pending' => $pendingThanks->values(),
                'completed' => $sentThanks->values(),
            ],
        ]]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageRegistry($request);

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
        $this->ensureCanManageRegistry($request);

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
            'is_visible'         => 'boolean',
            'is_priority'        => 'boolean',
        ]);

        $registryItem->update($data);

        return response()->json(['data' => $registryItem->fresh()]);
    }

    /**
     * Bulk visibility toggle used by the "Registry" guest-link picker —
     * mirrors updateTransportVisibility()/updateAccommodationVisibility()
     * in LogisticsController.
     */
    public function updateVisibility(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageRegistry($request);

        $data = $request->validate([
            'visible_ids' => 'present|array',
            'visible_ids.*' => 'integer|exists:registry_items,id',
        ]);

        $wedding->registryItems()->update(['is_visible' => false]);
        if (! empty($data['visible_ids'])) {
            $wedding->registryItems()->whereIn('id', $data['visible_ids'])->update(['is_visible' => true]);
        }

        return response()->json(['data' => $wedding->registryItems()->orderBy('sort_order')->get()]);
    }

    public function destroy(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        $this->ensureCanManageRegistry($request);
        $registryItem->delete();
        return response()->json(null, 204);
    }

    public function contributions(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        return response()->json(['data' => $registryItem->contributions()->with('guest')->get()]);
    }

    public function contribute(Request $request, RegistryItem $registryItem): JsonResponse
    {
        $this->authorizeItem($request, $registryItem);
        $this->ensureCanManageRegistry($request);

        $data = $request->validate([
            'guest_id' => 'nullable|integer|exists:guests,id',
            'contributor_name' => 'required|string|max:255',
            'contributor_email' => 'nullable|email|max:255',
            'amount' => 'nullable|numeric|min:0',
            'quantity' => 'nullable|integer|min:1',
            'payment_status' => 'nullable|in:pending,completed,refunded',
            'message' => 'nullable|string',
        ]);

        if (($data['guest_id'] ?? null) && ! $registryItem->wedding->guests()->whereKey($data['guest_id'])->exists()) {
            abort(403);
        }

        $contribution = $registryItem->contributions()->create([
            ...$data,
            'wedding_id' => $registryItem->wedding_id,
            'payment_status' => $data['payment_status'] ?? 'completed',
            'quantity' => $data['quantity'] ?? 1,
            'paid_at' => ($data['payment_status'] ?? 'completed') === 'completed' ? now() : null,
        ]);
        $this->refreshRegistryItemTotals($registryItem);
        $this->ensureThankYouRecord($contribution);

        return response()->json(['data' => $contribution->load(['item', 'guest'])], 201);
    }

    public function thankYous(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $records = ThankYouRecord::query()
            ->where('wedding_id', $wedding->id)
            ->with(['contribution.item', 'guest'])
            ->latest()
            ->get();

        return response()->json(['data' => $records]);
    }

    public function markThanked(Request $request, RegistryContribution $contribution): JsonResponse
    {
        abort_unless($contribution->wedding_id === $this->wedding($request)->id, 403);
        $this->ensureCanManageRegistry($request);

        $data = $request->validate([
            'note' => 'nullable|string',
            'channel' => 'nullable|in:email,card,verbal,sms,whatsapp',
        ]);

        $record = $this->ensureThankYouRecord($contribution);
        $record->update([
            'note' => $data['note'] ?? $record->note,
            'channel' => $data['channel'] ?? $record->channel,
            'status' => 'sent',
            'sent_at' => now(),
        ]);
        $contribution->update(['thank_you_sent' => true]);

        return response()->json(['data' => $record->fresh()->load(['contribution.item', 'guest'])]);
    }

    private function authorizeItem(Request $request, RegistryItem $registryItem): void
    {
        abort_unless($registryItem->wedding_id === $this->wedding($request)->id, 403);
    }

    private function refreshRegistryItemTotals(RegistryItem $item): void
    {
        $completed = $item->contributions()->where('payment_status', 'completed');
        $item->update([
            'fund_raised' => (float) $completed->sum('amount'),
            'quantity_purchased' => (int) $completed->sum('quantity'),
        ]);
    }

    private function ensureThankYouRecord(RegistryContribution $contribution): ThankYouRecord
    {
        return ThankYouRecord::firstOrCreate(
            ['contribution_id' => $contribution->id],
            [
                'wedding_id' => $contribution->wedding_id,
                'guest_id' => $contribution->guest_id,
                'recipient_name' => $contribution->contributor_name,
                'recipient_email' => $contribution->contributor_email,
                'reason' => 'gift',
                'channel' => $contribution->contributor_email ? 'email' : 'card',
                'status' => $contribution->thank_you_sent ? 'sent' : 'pending',
                'sent_at' => $contribution->thank_you_sent ? now() : null,
            ]
        );
    }
}
