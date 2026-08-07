<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\WeddingDocument;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class WeddingDocumentController extends Controller
{
    private const FOLDERS = ['Contracts', 'Payments', 'Insurance', 'Travel', 'Wedding Party', 'Registry', 'Generated', 'Uploads'];

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
        return response()->json(['data' => $this->wedding($request)->weddingDocuments()->with('uploader:id,name')->get()]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'file' => 'required|file|max:20480',
            'folder' => ['nullable', 'string', 'in:' . implode(',', self::FOLDERS)],
        ]);

        $uploaded = $request->file('file');
        $path = $uploaded->store("weddings/{$wedding->id}/documents", 'public');

        $document = $wedding->weddingDocuments()->create([
            'uploaded_by' => $request->user()->id,
            'folder' => $data['folder'] ?? 'Uploads',
            'name' => $uploaded->getClientOriginalName(),
            'url' => Storage::url($path),
            'file_size_bytes' => $uploaded->getSize(),
        ]);

        return response()->json(['data' => $document->load('uploader:id,name')], 201);
    }

    public function destroy(Request $request, WeddingDocument $weddingDocument): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);
        abort_unless($weddingDocument->wedding_id === $wedding->id, 403);
        $weddingDocument->delete();
        return response()->json(null, 204);
    }
}
