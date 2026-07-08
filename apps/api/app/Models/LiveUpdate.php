<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LiveUpdate extends Model
{
    protected $fillable = [
        'wedding_id', 'created_by', 'type', 'title', 'body',
        'image_url', 'pinned', 'visible_to_guests', 'bride_only', 'event_time',
    ];

    protected $casts = [
        'pinned' => 'boolean',
        'visible_to_guests' => 'boolean',
        'bride_only' => 'boolean',
        'event_time' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function creator(): BelongsTo { return $this->belongsTo(User::class, 'created_by'); }
}
