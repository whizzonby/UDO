<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemoryVow extends Model
{
    protected $fillable = [
        'wedding_id', 'title', 'draft_text', 'file_path', 'is_private',
        'is_final', 'printing_status', 'has_backup', 'viewed_at',
    ];

    protected $casts = [
        'is_private' => 'boolean',
        'is_final' => 'boolean',
        'has_backup' => 'boolean',
        'viewed_at' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
