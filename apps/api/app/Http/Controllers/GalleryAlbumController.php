<?php

namespace App\Http\Controllers;

use App\Models\GalleryAlbum;
use App\Models\GalleryAsset;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GalleryAlbumController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return $wedding;
    }

    private function ensureCanManageGallery(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_gallery'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $albums = $wedding->galleryAlbums()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get()
            ->map(fn (GalleryAlbum $album) => $this->albumPayload($album));

        return response()->json(['data' => $albums]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGallery($request);

        $data = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string|max:500',
        ]);

        $album = $wedding->galleryAlbums()->firstOrCreate(
            ['name' => trim($data['name'])],
            [
                'description' => $data['description'] ?? null,
                'sort_order' => ($wedding->galleryAlbums()->max('sort_order') ?? 0) + 1,
            ]
        );

        return response()->json(['data' => $this->albumPayload($album->fresh())], $album->wasRecentlyCreated ? 201 : 200);
    }

    public function update(Request $request, GalleryAlbum $album): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($album->wedding_id === $wedding->id, 403);
        $this->ensureCanManageGallery($request);

        $data = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string|max:500',
        ]);

        $oldName = $album->name;
        $album->update([
            'name' => trim($data['name']),
            'description' => $data['description'] ?? null,
        ]);

        if ($oldName !== $album->name) {
            $wedding->galleryAssets()
                ->where('board_name', $oldName)
                ->update(['board_name' => $album->name]);
        }

        return response()->json(['data' => $this->albumPayload($album->fresh())]);
    }

    public function destroy(Request $request, GalleryAlbum $album): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($album->wedding_id === $wedding->id, 403);
        $this->ensureCanManageGallery($request);

        $wedding->galleryAssets()
            ->where('board_name', $album->name)
            ->update(['board_name' => null]);

        $album->delete();

        return response()->json(null, 204);
    }

    private function albumPayload(GalleryAlbum $album): array
    {
        $assets = GalleryAsset::query()
            ->where('wedding_id', $album->wedding_id)
            ->where('board_name', $album->name)
            ->latest()
            ->get();
        $cover = $assets->first();

        return [
            'id' => $album->id,
            'name' => $album->name,
            'description' => $album->description,
            'sort_order' => $album->sort_order,
            'asset_count' => $assets->count(),
            'cover_thumbnail_url' => $cover?->thumbnail_url ?? $cover?->url,
            'created_at' => $album->created_at,
            'updated_at' => $album->updated_at,
        ];
    }
}
