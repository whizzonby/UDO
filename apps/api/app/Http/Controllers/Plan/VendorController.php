<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use App\Services\ApprovalGatingService;
use App\Services\WeddingAccessService;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManageVendors(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_vendors'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        $vendors = $this->filteredVendors($request)
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $vendors]);
    }

    public function export(Request $request)
    {
        $vendors = $this->filteredVendors($request, false)
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        $rows = $vendors->map(fn (Vendor $vendor) => [
            $vendor->name,
            $vendor->category,
            $vendor->booking_status,
            $vendor->contact_person,
            $vendor->email,
            $vendor->phone,
            $vendor->contract_signed ? 'yes' : 'no',
            $vendor->priority,
        ])->prepend(['name', 'category', 'booking_status', 'contact_person', 'email', 'phone', 'contract_signed', 'priority']);

        return response($this->csv($rows), 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="vendors.csv"',
        ]);
    }

    private function filteredVendors(Request $request, bool $withRelations = true)
    {
        $query = $this->wedding($request)
            ->vendors()
            ->when($request->search, fn ($query) => $query->where(function ($search) use ($request) {
                $search->where('name', 'like', "%{$request->search}%")
                    ->orWhere('category', 'like', "%{$request->search}%")
                    ->orWhere('contact_person', 'like', "%{$request->search}%")
                    ->orWhere('email', 'like', "%{$request->search}%")
                    ->orWhere('phone', 'like', "%{$request->search}%");
            }))
            ->when($request->category, fn ($query) => $query->where('category', $request->category))
            ->when($request->status, fn ($query) => $query->where('booking_status', $request->status))
            ->when($request->priority, fn ($query) => $query->where('priority', $request->priority))
            ->when($request->has('contract_signed'), fn ($query) => $query->where('contract_signed', $request->boolean('contract_signed')));

        if ($withRelations) {
            $query->with(['budgetItems', 'tasks' => fn ($query) => $query->where('completed', false)->orderBy('due_date'), 'contactLogs' => fn ($query) => $query->limit(3)])
                ->withCount(['contactLogs', 'tasks']);
        }

        return $query;
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageVendors($request);

        $data = $request->validate([
            'name'             => 'required|string|max:255',
            'category'         => 'nullable|string|max:100',
            'contact_person'   => 'nullable|string|max:255',
            'email'            => 'nullable|email',
            'phone'            => 'nullable|string|max:50',
            'website'          => 'nullable|url',
            'instagram'        => 'nullable|string|max:100',
            'quoted_price'     => 'nullable|numeric|min:0',
            'deposit_paid'     => 'nullable|numeric|min:0',
            'balance_due'      => 'nullable|numeric|min:0',
            'deposit_due_date'  => 'nullable|date',
            'balance_due_date'  => 'nullable|date',
            'booking_status'   => 'nullable|in:researching,negotiating,booked,confirmed,cancelled',
            'contract_signed'  => 'nullable|boolean',
            'contract_file_url' => 'nullable|url',
            'on_timeline'      => 'nullable|boolean',
            'priority'         => 'nullable|in:low,medium,high',
            'notes'            => 'nullable|string',
        ]);

        $vendor = $wedding->vendors()->create($data);

        return response()->json(['data' => $vendor], 201);
    }

    public function show(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);
        return response()->json(['data' => $vendor->load('budgetItems')]);
    }

    public function update(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);
        $wedding = $this->wedding($request);
        $this->ensureCanManageVendors($request);

        $data = $request->validate([
            'name'             => 'sometimes|string|max:255',
            'category'         => 'nullable|string|max:100',
            'contact_person'   => 'nullable|string|max:255',
            'email'            => 'nullable|email',
            'phone'            => 'nullable|string|max:50',
            'website'          => 'nullable|url',
            'instagram'        => 'nullable|string|max:100',
            'quoted_price'     => 'nullable|numeric|min:0',
            'deposit_paid'     => 'nullable|numeric|min:0',
            'balance_due'      => 'nullable|numeric|min:0',
            'deposit_due_date'  => 'nullable|date',
            'balance_due_date'  => 'nullable|date',
            'booking_status'   => 'nullable|in:researching,negotiating,booked,confirmed,cancelled',
            'checked_in_at'    => 'nullable|date',
            'contract_signed'  => 'nullable|boolean',
            'contract_file_url' => 'nullable|url',
            'on_timeline'      => 'nullable|boolean',
            'priority'         => 'nullable|in:low,medium,high',
            'notes'            => 'nullable|string',
        ]);

        $isConfirming = ($data['booking_status'] ?? null) === 'confirmed' && $vendor->booking_status !== 'confirmed';

        if ($isConfirming) {
            $result = app(ApprovalGatingService::class)->requestOrApply(
                $wedding,
                'vendors',
                $vendor,
                $data,
                $request->user(),
                "Confirm vendor: {$vendor->name}",
                "Booking status changing to confirmed for {$vendor->name}.",
            );

            if ($result['gated']) {
                return response()->json([
                    'data' => $vendor->fresh(),
                    'gated' => true,
                    'approval_request_id' => $result['request']->id,
                ]);
            }

            return response()->json(['data' => $result['subject'], 'gated' => false]);
        }

        $vendor->update($data);

        return response()->json(['data' => $vendor->fresh(), 'gated' => false]);
    }

    public function destroy(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);
        $this->ensureCanManageVendors($request);
        $vendor->delete();
        return response()->json(null, 204);
    }

    public function bulkUpdate(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageVendors($request);

        $data = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer',
            'updates' => 'required|array',
            'updates.booking_status' => 'nullable|in:researching,negotiating,booked,confirmed,cancelled',
            'updates.contract_signed' => 'nullable|boolean',
            'updates.on_timeline' => 'nullable|boolean',
            'updates.priority' => 'nullable|in:low,medium,high',
            'updates.category' => 'nullable|string|max:100',
            'confirm' => 'accepted',
        ]);

        $updates = collect($data['updates'])->only(['booking_status', 'contract_signed', 'on_timeline', 'priority', 'category'])->all();
        abort_if(empty($updates), 422, 'No supported updates were provided.');

        $vendors = $wedding->vendors()->whereIn('id', $data['ids'])->get();
        abort_unless($vendors->count() === count(array_unique($data['ids'])), 422, 'One or more vendors do not belong to this wedding.');

        $isConfirming = ($updates['booking_status'] ?? null) === 'confirmed';

        if ($isConfirming) {
            $gating = app(ApprovalGatingService::class);
            $pendingCount = 0;
            $appliedCount = 0;

            foreach ($vendors as $vendor) {
                if ($vendor->booking_status === 'confirmed') {
                    continue;
                }
                $result = $gating->requestOrApply(
                    $wedding, 'vendors', $vendor, $updates, $request->user(),
                    "Confirm vendor: {$vendor->name}",
                    "Booking status changing to confirmed for {$vendor->name}.",
                );
                $result['gated'] ? $pendingCount++ : $appliedCount++;
            }

            return response()->json([
                'updated' => $appliedCount,
                'pending_approval' => $pendingCount,
                'data' => $wedding->vendors()->whereIn('id', $data['ids'])->orderBy('category')->orderBy('name')->get(),
            ]);
        }

        $wedding->vendors()->whereIn('id', $data['ids'])->update($updates);

        return response()->json([
            'updated' => $vendors->count(),
            'pending_approval' => 0,
            'data' => $wedding->vendors()->whereIn('id', $data['ids'])->orderBy('category')->orderBy('name')->get(),
        ]);
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $vendors = $wedding->vendors()
            ->with(['budgetItems', 'tasks' => fn ($query) => $query->where('completed', false)->orderBy('due_date'), 'contactLogs' => fn ($query) => $query->limit(3)])
            ->withCount(['contactLogs', 'tasks'])
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        $recentContactLogs = $wedding->vendors()
            ->with(['contactLogs' => fn ($query) => $query->latest('contact_at')->latest()->limit(1)])
            ->get()
            ->flatMap(fn (Vendor $vendor) => $vendor->contactLogs->map(fn ($log) => [
                'id' => $log->id,
                'vendor_id' => $vendor->id,
                'vendor_name' => $vendor->name,
                'contact_type' => $log->contact_type,
                'subject' => $log->subject,
                'outcome' => $log->outcome,
                'contact_at' => optional($log->contact_at)->toISOString(),
                'follow_up_at' => optional($log->follow_up_at)->toISOString(),
            ]))
            ->sortByDesc('contact_at')
            ->values()
            ->take(8);

        return response()->json([
            'data' => [
                'vendor_count' => $vendors->count(),
                'confirmed_count' => $vendors->filter(fn (Vendor $vendor) => $this->isConfirmed($vendor))->count(),
                'researching_count' => $vendors->where('booking_status', 'researching')->count(),
                'negotiating_count' => $vendors->where('booking_status', 'negotiating')->count(),
                'missing_contracts' => $vendors->filter(fn (Vendor $vendor) => $this->isConfirmed($vendor) && !$vendor->contract_signed)->count(),
                'unpaid_balance' => round($vendors->sum(fn (Vendor $vendor) => (float) $vendor->balance_due), 2),
                'deposits_due_soon' => $this->dueSoon($vendors, 'deposit_due_date')->values(),
                'balances_due_soon' => $this->dueSoon($vendors, 'balance_due_date')->values(),
                'priority_vendors' => $vendors->filter(fn (Vendor $vendor) => $this->isPriority($vendor))->map(fn (Vendor $vendor) => $this->vendorCard($vendor))->values(),
                'day_of_contact_sheet' => $this->dayOfRows($vendors),
                'recent_contact_logs' => $recentContactLogs,
            ],
        ]);
    }

    public function dayOfContactSheet(Request $request): JsonResponse
    {
        $vendors = $this->wedding($request)
            ->vendors()
            ->with(['tasks' => fn ($query) => $query->where('completed', false)->orderBy('due_date')])
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $this->dayOfRows($vendors)]);
    }

    public function contactLogs(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);

        return response()->json([
            'data' => $vendor->contactLogs()
                ->with('creator:id,name,email')
                ->latest('contact_at')
                ->latest()
                ->get(),
        ]);
    }

    public function storeContactLog(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);
        $this->ensureCanManageVendors($request);

        $data = $request->validate([
            'contact_type' => 'nullable|in:email,call,sms,meeting,note',
            'subject' => 'required|string|max:255',
            'body' => 'nullable|string',
            'outcome' => 'nullable|string|max:255',
            'contact_at' => 'nullable|date',
            'follow_up_at' => 'nullable|date',
        ]);

        $log = $vendor->contactLogs()->create([
            ...$data,
            'wedding_id' => $vendor->wedding_id,
            'created_by' => $request->user()->id,
            'contact_type' => $data['contact_type'] ?? 'note',
            'contact_at' => $data['contact_at'] ?? now(),
        ]);

        return response()->json(['data' => $log->load('creator:id,name,email')], 201);
    }

    private function authorize(Request $request, Vendor $vendor): void
    {
        abort_unless($vendor->wedding_id === $this->wedding($request)->id, 403);
    }

    private function dueSoon(Collection $vendors, string $field)
    {
        return $vendors
            ->filter(fn (Vendor $vendor) => $vendor->{$field} && $vendor->{$field}->betweenIncluded(now()->startOfDay(), now()->addDays(14)->endOfDay()))
            ->sortBy($field)
            ->map(fn (Vendor $vendor) => [
                ...$this->vendorCard($vendor),
                'due_date' => optional($vendor->{$field})->toDateString(),
                'amount_due' => $field === 'deposit_due_date' ? (float) $vendor->deposit_paid : (float) $vendor->balance_due,
            ]);
    }

    private function dayOfRows(Collection $vendors)
    {
        return $vendors
            ->filter(fn (Vendor $vendor) => $this->isConfirmed($vendor) || $vendor->on_timeline || $this->isPriority($vendor))
            ->sortBy([
                fn (Vendor $a, Vendor $b) => strcmp((string) $b->priority, (string) $a->priority),
                fn (Vendor $a, Vendor $b) => strcmp($a->category, $b->category),
            ])
            ->map(fn (Vendor $vendor) => [
                ...$this->vendorCard($vendor),
                'contact_person' => $vendor->contact_person,
                'email' => $vendor->email,
                'phone' => $vendor->phone,
                'on_timeline' => (bool) $vendor->on_timeline,
                'open_task_count' => $vendor->tasks->where('completed', false)->count(),
                'next_task' => optional($vendor->tasks->where('completed', false)->sortBy('due_date')->first())->only(['id', 'title', 'due_date', 'priority']),
                'balance_due' => (float) $vendor->balance_due,
                'contract_signed' => (bool) $vendor->contract_signed,
                'notes' => $vendor->notes,
            ])
            ->values();
    }

    private function vendorCard(Vendor $vendor): array
    {
        return [
            'id' => $vendor->id,
            'name' => $vendor->name,
            'category' => $vendor->category,
            'booking_status' => $vendor->booking_status,
            'priority' => $vendor->priority,
            'contract_signed' => (bool) $vendor->contract_signed,
            'contact_logs_count' => $vendor->contact_logs_count ?? $vendor->contactLogs->count(),
            'tasks_count' => $vendor->tasks_count ?? $vendor->tasks->count(),
        ];
    }

    private function isConfirmed(Vendor $vendor): bool
    {
        return in_array($vendor->booking_status, ['booked', 'confirmed', 'paid'], true);
    }

    private function isPriority(Vendor $vendor): bool
    {
        return in_array((string) $vendor->priority, ['high', '1'], true) || $vendor->priority === true;
    }

    private function csv($rows): string
    {
        return $rows->map(fn ($row) => collect($row)->map(fn ($value) => '"' . str_replace('"', '""', (string) $value) . '"')->implode(','))->implode("\n") . "\n";
    }
}
