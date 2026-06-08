<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GalleryItem extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id', 'type', 'title', 'caption', 'image_url',
        'category', 'is_featured', 'source_url', 'uploaded_by', 'sort_order',
    ];

    protected $casts = [
        'is_featured' => 'boolean',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
