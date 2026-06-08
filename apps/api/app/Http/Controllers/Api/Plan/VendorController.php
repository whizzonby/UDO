<?php

namespace App\Http\Controllers\Api\Plan;

use App\Http\Controllers\Controller;
use App\Http\Requests\Plan\StoreVendorRequest;
use App\Http\Requests\Plan\UpdateVendorRequest;
use App\Http\Resources\VendorResource;
use App\Models\Vendor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VendorController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        return VendorResource::collection($wedding->vendors()->latest()->get());
    }

    public function store(StoreVendorRequest $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->firstOrFail();
        $vendor  = $wedding->vendors()->create($request->validated());

        return response()->json(new VendorResource($vendor), 201);
    }

    public function update(UpdateVendorRequest $request, Vendor $vendor): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $vendor->wedding_id)->exists(),
            403
        );

        $data = $request->validated();

        if (isset($data['status']) && $data['status'] === 'paid' && ! $vendor->deposit_paid_at) {
            $data['deposit_paid_at'] = now();
        }

        $vendor->update($data);

        return response()->json(new VendorResource($vendor->fresh()));
    }

    public function destroy(Request $request, Vendor $vendor): JsonResponse
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $vendor->wedding_id)->exists(),
            403
        );

        $vendor->delete();

        return response()->json(['message' => 'Vendor deleted.']);
    }
}
