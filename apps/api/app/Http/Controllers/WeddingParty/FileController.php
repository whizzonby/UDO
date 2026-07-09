<?php

namespace App\Http\Controllers\WeddingParty;

use App\Http\Controllers\Controller;
use App\Models\WeddingPartyFile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FileController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $items = $this->wedding($request)
            ->weddingPartyFiles()
            ->with(['guest:id,first_name,last_name', 'uploader:id,name'])
            ->when($request->category, fn($q) => $q->where('category', $request->category))
            ->get();

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');

        $request->validate([
            'file'     => 'required|file|max:20480',
            'category' => 'nullable|in:file,speech',
            'guest_id' => 'nullable|integer|exists:guests,id',
        ]);

        $uploaded = $request->file('file');
        $path = $uploaded->store("weddings/{$wedding->id}/wedding-party", 'public');

        $item = $wedding->weddingPartyFiles()->create([
            'guest_id'        => $request->input('guest_id'),
            'uploaded_by'     => $request->user()->id,
            'category'        => $request->input('category', 'file'),
            'name'            => $uploaded->getClientOriginalName(),
            'url'             => Storage::url($path),
            'file_size_bytes' => $uploaded->getSize(),
        ]);

        return response()->json(['data' => $item->load(['guest:id,first_name,last_name', 'uploader:id,name'])], 201);
    }

    public function destroy(Request $request, WeddingPartyFile $file): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($file->wedding_id === $wedding->id, 403);

        $path = str_replace('/storage/', '', $file->url);
        Storage::disk('public')->delete($path);
        $file->delete();

        return response()->json(null, 204);
    }
}
