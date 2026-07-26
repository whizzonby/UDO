<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemoryPhotoBooth extends Model
{
    protected $fillable = [
        'wedding_id', 'vendor_name', 'setup_time', 'location', 'props',
        'backdrop', 'sharing_method', 'guest_access', 'status',
    ];

    protected $casts = [
        'guest_access' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
