<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\InsuranceDocument;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class InsuranceDocumentController extends Controller
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
        return response()->json(['data' => $this->wedding($request)->insuranceDocuments()->with('uploader:id,name')->get()]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $request->validate([
            'file' => 'required|file|max:20480',
        ]);

        $uploaded = $request->file('file');
        $path = $uploaded->store("weddings/{$wedding->id}/insurance", 'public');

        $document = $wedding->insuranceDocuments()->create([
            'uploaded_by' => $request->user()->id,
            'name' => $uploaded->getClientOriginalName(),
            'url' => Storage::url($path),
            'file_size_bytes' => $uploaded->getSize(),
        ]);

        return response()->json(['data' => $document->load('uploader:id,name')], 201);
    }

    public function destroy(Request $request, InsuranceDocument $insuranceDocument): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);
        abort_unless($insuranceDocument->wedding_id === $wedding->id, 403);
        $insuranceDocument->delete();
        return response()->json(null, 204);
    }
}
