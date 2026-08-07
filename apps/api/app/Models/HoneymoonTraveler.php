<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HoneymoonTraveler extends Model
{
    protected $fillable = [
        'honeymoon_trip_id', 'name', 'role',
    ];

    public function trip(): BelongsTo { return $this->belongsTo(HoneymoonTrip::class, 'honeymoon_trip_id'); }
}
