<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingWeekendEvent extends Model
{
    protected $fillable = [
        'wedding_id', 'title', 'event_date', 'start_time', 'end_time', 'location',
        'description', 'audience', 'dress_code', 'host', 'notes',
    ];

    protected $casts = [
        'event_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
