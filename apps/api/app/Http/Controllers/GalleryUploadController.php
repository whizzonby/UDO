<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use App\Models\GuestExperienceConfig;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

/**
 * Public, wedding-wide upload link reached via a QR code — unlike
 * GuestPortalController::uploadPhoto, this isn't tied to any one guest's
 * invite token, so uploads carry an optional free-text name instead of a
 * real Guest identity.
 */
class GalleryUploadController extends Controller
{
    public function show(string $token): JsonResponse
    {
        $wedding = Wedding::where('gallery_upload_token', $token)->firstOrFail();
        $config = $this->experienceConfig($wedding);

        return response()->json(['data' => [
            'couple_name_primary' => $wedding->couple_name_primary,
            'couple_name_secondary' => $wedding->couple_name_secondary,
            'venue' => $wedding->primary_venue_name,
            'uploads_open' => $config->publish_state === 'published' && $config->allow_photo_uploads,
        ]]);
    }

    public function store(Request $request, string $token): JsonResponse
    {
        $wedding = Wedding::where('gallery_upload_token', $token)->firstOrFail();
        $config = $this->experienceConfig($wedding);
        abort_unless($config->publish_state === 'published' && $config->allow_photo_uploads, 403, 'Photo uploads are not currently open.');

        $data = $request->validate([
            'file' => 'required|file|mimes:jpg,jpeg,png,gif,webp,mp4,mov,webm,mp3,wav,m4a,aac,ogg|max:51200',
            'caption' => 'nullable|string|max:255',
            'uploaded_by_name' => 'nullable|string|max:100',
        ]);

        $file = $data['file'];
        $path = $file->store("weddings/{$wedding->id}/guest-uploads", 'public');
        $url = Storage::url($path);
        $mimeType = (string) $file->getMimeType();

        $asset = $wedding->galleryAssets()->create([
            'uploaded_by_name' => $data['uploaded_by_name'] ?? null,
            'type' => GalleryAsset::resolveTypeFromMime($mimeType),
            'source' => 'upload',
            'url' => $url,
            'thumbnail_url' => $url,
            'original_filename' => $file->getClientOriginalName(),
            'file_size_bytes' => $file->getSize(),
            'album' => 'guest_uploads',
            'caption' => $data['caption'] ?? null,
            'approved' => false,
        ]);

        return response()->json(['data' => $asset, 'message' => 'Photo uploaded for review.'], 201);
    }

    private function experienceConfig(Wedding $wedding): GuestExperienceConfig
    {
        return $wedding->experienceConfig ?? $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'published_at' => now(),
        ]);
    }
}
