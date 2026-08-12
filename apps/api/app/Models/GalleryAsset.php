<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class GalleryAsset extends Model
{
    protected $fillable = [
        'wedding_id', 'uploaded_by_user_id', 'uploaded_by_guest_id', 'uploaded_by_name',
        'type', 'source', 'url', 'thumbnail_url', 'original_filename',
        'file_size_bytes', 'album', 'board_name', 'category', 'journey_stage', 'caption', 'is_featured', 'is_saved', 'approved',
        'pinterest_source_url', 'visible_to_guests',
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'is_saved' => 'boolean',
        'approved' => 'boolean',
        'visible_to_guests' => 'boolean',
        'file_size_bytes' => 'integer',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function uploadedByUser(): BelongsTo { return $this->belongsTo(User::class, 'uploaded_by_user_id'); }
    public function uploadedByGuest(): BelongsTo { return $this->belongsTo(Guest::class, 'uploaded_by_guest_id'); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }

    public static function resolveTypeFromMime(string $mimeType): string
    {
        if (str_starts_with($mimeType, 'video/')) {
            return 'video';
        }
        if (str_starts_with($mimeType, 'audio/')) {
            return 'voice';
        }
        return 'photo';
    }
}
