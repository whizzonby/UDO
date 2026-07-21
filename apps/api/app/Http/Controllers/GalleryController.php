<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GalleryController extends Controller
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
        $assets = $this->wedding($request)
            ->galleryAssets()
            ->with('uploadedByGuest:id,first_name,last_name')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (GalleryAsset $asset) => $this->assetPayload($asset));

        return response()->json(['data' => $assets]);
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $assets = $wedding->galleryAssets()
            ->with('uploadedByGuest:id,first_name,last_name')
            ->latest()
            ->get()
            ->map(fn (GalleryAsset $asset) => $this->assetPayload($asset));

        return response()->json(['data' => [
            'total_assets' => $assets->count(),
            'approved_assets' => $assets->where('approved', true)->count(),
            'pending_assets' => $assets->where('approved', false)->where('album', 'guest_uploads')->count(),
            'featured_assets' => $assets->where('is_featured', true)->count(),
            'saved_assets' => $assets->where('is_saved', true)->count(),
            'archived_assets' => $assets->where('album', 'archive')->count(),
            'albums' => [
                'inspiration' => $assets->where('album', 'inspiration')->values(),
                'moments' => $assets->where('album', 'moments')->where('approved', true)->values(),
                'guest_uploads_pending' => $assets->where('album', 'guest_uploads')->where('approved', false)->values(),
                'guest_uploads_approved' => $assets->where('album', 'guest_uploads')->where('approved', true)->values(),
                'saved' => $assets->where('is_saved', true)->values(),
                'featured' => $assets->where('is_featured', true)->where('approved', true)->values(),
                'archive' => $assets->where('album', 'archive')->values(),
            ],
        ]]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGallery($request);

        $request->validate([
            'file'  => 'required_without:url|file|mimes:jpg,jpeg,png,gif,webp,mp4,mov|max:51200',
            'url'   => 'required_without:file|nullable|url',
            'type'  => 'nullable|in:photo,video',
            'album' => 'nullable|in:moments,inspiration,guest_uploads,archive',
            'source' => 'nullable|in:upload,guest_upload,pinterest,instagram',
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
            'caption'      => $request->input('title'),
            'uploaded_by_user_id' => $request->user()->id,
            'approved'     => true,
        ]);

        return response()->json(['data' => $this->assetPayload($asset->fresh())], 201);
    }

    public function show(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        return response()->json(['data' => $galleryAsset]);
    }

    public function update(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

        $data = $request->validate([
            'album'    => 'nullable|in:moments,inspiration,guest_uploads,archive',
            'title'    => 'nullable|string|max:255',
            'approved' => 'nullable|boolean',
            'is_featured' => 'nullable|boolean',
            'is_saved' => 'nullable|boolean',
        ]);

        if (array_key_exists('title', $data)) {
            $data['caption'] = $data['title'];
            unset($data['title']);
        }

        $galleryAsset->update($data);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    public function approve(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

        $galleryAsset->update([
            'approved' => true,
            'album' => $galleryAsset->album === 'archive' ? 'guest_uploads' : $galleryAsset->album,
        ]);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    public function reject(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

        $galleryAsset->update([
            'approved' => false,
            'is_featured' => false,
            'album' => 'archive',
        ]);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    public function feature(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

        $data = $request->validate([
            'is_featured' => 'required|boolean',
        ]);

        $galleryAsset->update([
            'is_featured' => $data['is_featured'],
            'approved' => $data['is_featured'] ? true : $galleryAsset->approved,
        ]);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    public function archive(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

        $galleryAsset->update([
            'album' => 'archive',
            'is_featured' => false,
        ]);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    public function destroy(Request $request, GalleryAsset $galleryAsset): JsonResponse
    {
        $this->authorizeAsset($request, $galleryAsset);
        $this->ensureCanManageGallery($request);

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

    private function assetPayload(GalleryAsset $asset): array
    {
        $asset->loadMissing('uploadedByGuest:id,first_name,last_name');
        $payload = $asset->toArray();
        $payload['uploaded_by_guest_name'] = $asset->uploadedByGuest?->full_name;
        return $payload;
    }
}
