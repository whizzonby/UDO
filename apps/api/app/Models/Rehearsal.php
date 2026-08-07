<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Rehearsal extends Model
{
    protected $fillable = [
        'wedding_id', 'title', 'color', 'location', 'location_place_id',
        'description', 'event_date', 'start_time', 'end_time', 'timezone',
        'audience', 'attendee_guest_ids', 'dress_code', 'bring_items',
        'schedule_items', 'notes', 'add_to_timeline', 'timeline_item_id',
    ];

    protected $casts = [
        'event_date' => 'date',
        'attendee_guest_ids' => 'array',
        'bring_items' => 'array',
        'schedule_items' => 'array',
        'add_to_timeline' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }

    public function timelineItem(): BelongsTo { return $this->belongsTo(TimelineItem::class); }
}
