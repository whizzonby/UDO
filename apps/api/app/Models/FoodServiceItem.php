<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FoodServiceItem extends Model
{
    protected $fillable = [
        'wedding_id', 'event_category', 'service_category', 'service_type',
        'event_date', 'start_time', 'end_time', 'location', 'description',
        'assigned_to', 'notes', 'status', 'priority',
    ];

    protected $casts = [
        'event_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
