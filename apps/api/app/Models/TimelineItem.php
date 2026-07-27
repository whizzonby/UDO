<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimelineItem extends Model
{
    protected $fillable = [
        'wedding_id', 'title', 'description', 'event_type', 'event_date',
        'start_time', 'end_time', 'duration_minutes', 'location',
        'location_address', 'location_status', 'assigned_vendors', 'guest_groups',
        'visible_to_guests', 'notes', 'sort_order',
    ];

    protected $casts = [
        'event_date' => 'date',
        'assigned_vendors' => 'array',
        'guest_groups' => 'array',
        'visible_to_guests' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
