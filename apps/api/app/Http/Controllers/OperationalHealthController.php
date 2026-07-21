<?php

namespace App\Http\Controllers;

use App\Services\OperationalHealthService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OperationalHealthController extends Controller
{
    public function show(Request $request, OperationalHealthService $health): JsonResponse
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return response()->json(['data' => $health->snapshot($wedding)]);
    }
}
