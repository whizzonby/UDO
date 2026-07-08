<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GalleryAsset extends Model
{
    protected $fillable = [
        'wedding_id', 'uploaded_by_user_id', 'uploaded_by_guest_id',
        'type', 'source', 'url', 'thumbnail_url', 'original_filename',
        'file_size_bytes', 'album', 'caption', 'is_featured', 'approved',
        'pinterest_source_url',
    ];

    protected $casts = [
        'is_featured' => 'boolean',
        'approved' => 'boolean',
        'file_size_bytes' => 'integer',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function uploadedByUser(): BelongsTo { return $this->belongsTo(User::class, 'uploaded_by_user_id'); }
    public function uploadedByGuest(): BelongsTo { return $this->belongsTo(Guest::class, 'uploaded_by_guest_id'); }
}
