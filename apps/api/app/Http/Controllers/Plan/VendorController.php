<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VendorController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $vendors = $this->wedding($request)
            ->vendors()
            ->orderBy('category')
            ->orderBy('name')
            ->get();

        return response()->json(['data' => $vendors]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'name'             => 'required|string|max:255',
            'category'         => 'nullable|string|max:100',
            'contact_name'     => 'nullable|string|max:255',
            'email'            => 'nullable|email',
            'phone'            => 'nullable|string|max:50',
            'website'          => 'nullable|url',
            'instagram'        => 'nullable|string|max:100',
            'quoted_price'     => 'nullable|numeric|min:0',
            'deposit_paid'     => 'nullable|numeric|min:0',
            'balance_due'      => 'nullable|numeric|min:0',
            'booking_status'   => 'nullable|in:researching,negotiating,booked,confirmed,cancelled',
            'contract_signed'  => 'nullable|boolean',
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

        $data = $request->validate([
            'name'             => 'sometimes|string|max:255',
            'category'         => 'nullable|string|max:100',
            'contact_name'     => 'nullable|string|max:255',
            'email'            => 'nullable|email',
            'phone'            => 'nullable|string|max:50',
            'website'          => 'nullable|url',
            'instagram'        => 'nullable|string|max:100',
            'quoted_price'     => 'nullable|numeric|min:0',
            'deposit_paid'     => 'nullable|numeric|min:0',
            'balance_due'      => 'nullable|numeric|min:0',
            'booking_status'   => 'nullable|in:researching,negotiating,booked,confirmed,cancelled',
            'contract_signed'  => 'nullable|boolean',
            'on_timeline'      => 'nullable|boolean',
            'priority'         => 'nullable|in:low,medium,high',
            'notes'            => 'nullable|string',
        ]);

        $vendor->update($data);

        return response()->json(['data' => $vendor->fresh()]);
    }

    public function destroy(Request $request, Vendor $vendor): JsonResponse
    {
        $this->authorize($request, $vendor);
        $vendor->delete();
        return response()->json(null, 204);
    }

    private function authorize(Request $request, Vendor $vendor): void
    {
        abort_unless($vendor->wedding_id === $this->wedding($request)->id, 403);
    }
}
