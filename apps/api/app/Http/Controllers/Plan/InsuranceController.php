<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\InsurancePolicy;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InsuranceController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManagePlan(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_plan'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->wedding($request)->insurancePolicies()->get()]);
    }

    private function rules(): array
    {
        return [
            'provider' => 'required|string|max:255',
            'policy_number' => 'nullable|string|max:255',
            'policy_type' => 'nullable|string|max:255',
            'coverage_amount' => 'nullable|numeric|min:0',
            'premium' => 'nullable|numeric|min:0',
            'deductible' => 'nullable|numeric|min:0',
            'purchase_date' => 'nullable|date',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date',
            'status' => 'nullable|in:active,expired,cancelled',
            'contact_number' => 'nullable|string|max:50',
            'notes' => 'nullable|string',
        ];
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules());
        $policy = $wedding->insurancePolicies()->create($data);

        return response()->json(['data' => $policy], 201);
    }

    public function update(Request $request, InsurancePolicy $insurancePolicy): JsonResponse
    {
        $this->authorizePolicy($request, $insurancePolicy);
        $this->ensureCanManagePlan($request);

        $rules = $this->rules();
        $rules['provider'] = 'sometimes|string|max:255';
        $data = $request->validate($rules);
        $insurancePolicy->update($data);

        return response()->json(['data' => $insurancePolicy->fresh()]);
    }

    public function destroy(Request $request, InsurancePolicy $insurancePolicy): JsonResponse
    {
        $this->authorizePolicy($request, $insurancePolicy);
        $this->ensureCanManagePlan($request);
        $insurancePolicy->delete();
        return response()->json(null, 204);
    }

    private function authorizePolicy(Request $request, InsurancePolicy $insurancePolicy): void
    {
        abort_unless($insurancePolicy->wedding_id === $this->wedding($request)->id, 403);
    }
}
