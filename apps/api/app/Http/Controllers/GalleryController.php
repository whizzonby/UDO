<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GalleryController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $assets = $this->wedding($request)
            ->galleryAssets()
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['data' => $assets]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $request->validate([
            'file'  => 'required_without:url|file|mimes:jpg,jpeg,png,gif,webp,mp4,mov|max:51200',
            'url'   => 'required_without:file|nullable|url',
            'type'  => 'nullable|in:photo,video',
            'album' => 'nullable|in:moments,inspiration,guest_uploads,archive',
            'source' => 'nullable|in:upload,pinterest,instagram',
            'title' => 'nullable|string|max:255',
        ]);

        $url = null;
        $thumbnailUrl = null;

        if ($request->hasFile('file')) {
            $path = $request->file('file')->store("weddings/{$wedding->id}/gallery", 'public');
            $url  = Storage::url($path);
        } else {
            $url = $request->input('url');
        }

        $asset = $wedding->galleryAssets()->create([
            'type'         => $request->input('type', 'photo'),
            'source'       => $request->input('source', 'upload'),
            'url'          => $url,
            'thumbnail_url' => $thumbnailUrl ?? $url,
            'album'        => $request->input('album', 'moments'),
            'title'        => $request->input('title'),
            'uploaded_by_user_id' => $request->user()->id,
            'approved'     => true,
        ]);

        return response()->json(['data' => $asset], 201);
    }

    public function show(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        return response()->json(['data' => $galleryAsset]);
    }

    public function update(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);

        $data = $request->validate([
            'album'    => 'nullable|in:moments,inspiration,guest_uploads,archive',
            'title'    => 'nullable|string|max:255',
            'approved' => 'nullable|boolean',
        ]);

        $galleryAsset->update($data);

        return response()->json(['data' => $galleryAsset->fresh()]);
    }

    public function destroy(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);

        if ($galleryAsset->source === 'upload' && $galleryAsset->url) {
            $path = str_replace('/storage/', '', $galleryAsset->url);
            Storage::disk('public')->delete($path);
        }

        $galleryAsset->delete();
        return response()->json(null, 204);
    }

    private function authorizeAsset(Request $request, GalleryAsset $galleryAsset): void
    {
        abort_unless($galleryAsset->wedding_id === $this->wedding($request)->id, 403);
    }
}
