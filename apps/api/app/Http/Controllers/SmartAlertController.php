<?php

namespace App\Http\Controllers;

use App\Models\SmartAlert;
use App\Services\SmartAlertService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SmartAlertController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return $wedding;
    }

    public function index(Request $request, SmartAlertService $alerts): JsonResponse
    {
        $wedding = $this->wedding($request);
        $includeResolved = $request->boolean('include_resolved');
        $alerts->refresh($wedding);

        $query = $wedding->smartAlerts()->orderByRaw("case severity when 'critical' then 1 when 'high' then 2 when 'medium' then 3 else 4 end");
        if (! $includeResolved) {
            $query->where('status', 'active');
        }

        return response()->json([
            'data' => $query->orderBy('trigger_at')->get()->map(fn (SmartAlert $alert) => $alerts->payload($alert))->values(),
            'summary' => $alerts->summary($wedding),
        ]);
    }

    public function refresh(Request $request, SmartAlertService $alerts): JsonResponse
    {
        return response()->json(['data' => $alerts->summary($this->wedding($request))]);
    }

    public function resolve(Request $request, SmartAlert $smartAlert, SmartAlertService $alerts): JsonResponse
    {
        abort_unless($smartAlert->wedding_id === $this->wedding($request)->id, 403);

        $smartAlert->update([
            'status' => 'resolved',
            'resolved_at' => now(),
        ]);

        return response()->json(['data' => $alerts->payload($smartAlert->fresh())]);
    }
}
