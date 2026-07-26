<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HoneymoonItem extends Model
{
    protected $fillable = [
        'honeymoon_trip_id', 'type', 'title', 'date', 'cost', 'details',
    ];

    protected $casts = [
        'date' => 'date',
        'cost' => 'decimal:2',
        'details' => 'array',
    ];

    public function trip(): BelongsTo { return $this->belongsTo(HoneymoonTrip::class, 'honeymoon_trip_id'); }
}
