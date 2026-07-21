<?php

namespace App\Services;

use App\Models\GalleryAsset;
use App\Models\User;
use Illuminate\Support\Arr;

class AdminGalleryModerationService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function moderate(GalleryAsset $asset, User $actor, string $action, ?string $note = null): GalleryAsset
    {
        $before = Arr::only($asset->toArray(), ['approved', 'is_featured', 'is_saved', 'album', 'caption']);

        match ($action) {
            'approve' => $asset->forceFill(['approved' => true]),
            'reject' => $asset->forceFill(['approved' => false, 'is_featured' => false]),
            'feature' => $asset->forceFill(['approved' => true, 'is_featured' => true]),
            'unfeature' => $asset->forceFill(['is_featured' => false]),
            'archive' => $asset->forceFill(['album' => 'archive', 'is_featured' => false]),
            'save' => $asset->forceFill(['is_saved' => true]),
            default => throw new \InvalidArgumentException('Unsupported gallery moderation action.'),
        };

        if ($note) {
            $asset->caption = trim(trim((string) $asset->caption) . "\nAdmin note: {$note}");
        }

        $asset->save();
        $fresh = $asset->fresh(['wedding', 'uploadedByUser', 'uploadedByGuest']);

        $this->auditLogService->record(
            "admin.gallery_asset_{$action}",
            wedding: $fresh->wedding,
            user: $actor,
            auditable: $fresh,
            before: $before,
            after: Arr::only($fresh->toArray(), ['approved', 'is_featured', 'is_saved', 'album', 'caption']),
            metadata: [
                'uploaded_by_user_id' => $fresh->uploaded_by_user_id,
                'uploaded_by_guest_id' => $fresh->uploaded_by_guest_id,
                'note' => $note,
            ],
            request: request(),
        );

        return $fresh;
    }
}
