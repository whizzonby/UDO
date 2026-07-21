<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Wedding;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding instanceof Wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'view_reports'), 403);

        $limit = max(1, min((int) $request->integer('limit', 50), 100));

        $logs = AuditLog::query()
            ->with('user:id,first_name,last_name,email,avatar_url')
            ->where('wedding_id', $wedding->id)
            ->when($request->action, fn ($query) => $query->where('action', $request->action))
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get();

        return response()->json(['data' => $logs]);
    }
}
