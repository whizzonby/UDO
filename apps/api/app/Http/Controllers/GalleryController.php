<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class GalleryController extends Controller
{
    /**
     * The doc's fixed inspiration-image taxonomy — a real, filterable
     * category tag, distinct from a user-named "board".
     */
    public const INSPIRATION_CATEGORIES = [
        'flowers', 'cake', 'tables', 'ceremony', 'dresses', 'suits',
        'lighting', 'stationery', 'photography', 'hair', 'makeup',
    ];

    /**
     * Real life-milestone tags a couple can attach to any asset (regardless
     * of album) to build the "Archive – Our Journey" timeline — distinct
     * from `album`, which tracks moderation state (moments/guest_uploads/
     * inspiration/archive-as-rejected), not chronology.
     */
    public const JOURNEY_STAGES = [
        'engagement', 'planning', 'wedding_weekend', 'honeymoon', 'anniversary', 'other',
    ];

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
            ->with('uploadedByGuest:id,first_name,last_name,wedding_party_role,guest_group,vip_flag')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (GalleryAsset $asset) => $this->assetPayload($asset));

        return response()->json(['data' => $assets]);
    }

    public function summary(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $assets = $wedding->galleryAssets()
            ->with('uploadedByGuest:id,first_name,last_name,wedding_party_role,guest_group,vip_flag')
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
            'boards' => $assets->where('album', 'inspiration')
                ->groupBy(fn (array $asset) => $asset['board_name'] ?: 'Unsorted')
                ->map(function ($group, $name) {
                    $sorted = $group->sortByDesc('created_at')->values();
                    return [
                        'name' => $name,
                        'count' => $sorted->count(),
                        'last_updated_at' => $sorted->first()['created_at'],
                        'cover_thumbnail_url' => $sorted->first()['thumbnail_url'] ?? $sorted->first()['url'],
                    ];
                })
                ->values(),
            'journey' => $assets->whereNotNull('journey_stage')
                ->groupBy(fn (array $asset) => $asset['journey_stage'])
                ->map(function ($group, $stage) {
                    $sorted = $group->sortByDesc('created_at')->values();
                    return [
                        'stage' => $stage,
                        'count' => $sorted->count(),
                        'last_updated_at' => $sorted->first()['created_at'],
                        'cover_thumbnail_url' => $sorted->first()['thumbnail_url'] ?? $sorted->first()['url'],
                    ];
                })
                ->values(),
        ]]);
    }

    public function uploadLink(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $token = $wedding->ensureGalleryUploadToken();
        $frontendUrl = rtrim(config('app.frontend_url'), '/');

        return response()->json(['data' => [
            'token' => $token,
            'url' => "{$frontendUrl}/upload/{$token}",
        ]]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGallery($request);

        $request->validate([
            'file'  => 'required_without:url|file|mimes:jpg,jpeg,png,gif,webp,mp4,mov,webm,mp3,wav,m4a,aac,ogg|max:51200',
            'url'   => 'required_without:file|nullable|url',
            'type'  => 'nullable|in:photo,video,voice',
            'album' => 'nullable|in:moments,inspiration,guest_uploads,archive',
            'category' => ['nullable', 'string', Rule::in(self::INSPIRATION_CATEGORIES)],
            'journey_stage' => ['nullable', 'string', Rule::in(self::JOURNEY_STAGES)],
            'source' => 'nullable|in:upload,guest_upload,pinterest,instagram',
            'title' => 'nullable|string|max:255',
        ]);

        $url = null;
        $thumbnailUrl = null;
        $resolvedType = $request->input('type');

        if ($request->hasFile('file')) {
            $path = $request->file('file')->store("weddings/{$wedding->id}/gallery", 'public');
            $url  = Storage::url($path);
            // A real file was uploaded — trust its actual mimetype over any
            // client-sent `type`, which the mobile app has never sent.
            $resolvedType = GalleryAsset::resolveTypeFromMime((string) $request->file('file')->getMimeType());
        } else {
            $url = $request->input('url');
            $resolvedType = $resolvedType ?? 'photo';
        }

        $asset = $wedding->galleryAssets()->create([
            'type'         => $resolvedType,
            'source'       => $request->input('source', 'upload'),
            'url'          => $url,
            'thumbnail_url' => $thumbnailUrl ?? $url,
            'album'        => $request->input('album', 'moments'),
            'category'     => $request->input('category'),
            'journey_stage' => $request->input('journey_stage'),
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
            'board_name' => 'nullable|string|max:100',
            'category' => ['nullable', 'string', Rule::in(self::INSPIRATION_CATEGORIES)],
            'journey_stage' => ['nullable', 'string', Rule::in(self::JOURNEY_STAGES)],
            'title'    => 'nullable|string|max:255',
            'approved' => 'nullable|boolean',
            'is_featured' => 'nullable|boolean',
            'is_saved' => 'nullable|boolean',
            'visible_to_guests' => 'nullable|boolean',
        ]);

        if (array_key_exists('title', $data)) {
            $data['caption'] = $data['title'];
            unset($data['title']);
        }

        $galleryAsset->update($data);

        return response()->json(['data' => $this->assetPayload($galleryAsset->fresh())]);
    }

    /**
     * Bulk visibility toggle used by the "Gallery" guest-link picker —
     * mirrors updateTransportVisibility()/updateAccommodationVisibility()
     * in LogisticsController. Kept separate from approve()/reject() so
     * curating the guest link never changes a photo's moderation status.
     */
    public function updateVisibility(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManageGallery($request);

        $data = $request->validate([
            'visible_ids' => 'present|array',
            'visible_ids.*' => 'integer|exists:gallery_assets,id',
        ]);

        $wedding->galleryAssets()->update(['visible_to_guests' => false]);
        if (! empty($data['visible_ids'])) {
            $wedding->galleryAssets()->whereIn('id', $data['visible_ids'])->update(['visible_to_guests' => true]);
        }

        $assets = $wedding->galleryAssets()
            ->with('uploadedByGuest:id,first_name,last_name,wedding_party_role,guest_group,vip_flag')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (GalleryAsset $asset) => $this->assetPayload($asset));

        return response()->json(['data' => $assets]);
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
        $asset->loadMissing('uploadedByGuest:id,first_name,last_name,wedding_party_role,guest_group,vip_flag');
        $guest = $asset->uploadedByGuest;
        $payload = $asset->toArray();
        $payload['uploaded_by_guest_name'] = $guest?->full_name;
        $payload['uploaded_by_role'] = match (true) {
            $guest !== null && ! empty($guest->wedding_party_role) => $guest->wedding_party_role,
            $guest !== null && $guest->vip_flag => 'VIP Guest',
            $guest !== null => 'Guest',
            ! empty($asset->uploaded_by_name) => $asset->uploaded_by_name,
            $asset->uploaded_by_guest_id !== null || $asset->album === 'guest_uploads' => 'Guest',
            default => null,
        };
        return $payload;
    }
}
