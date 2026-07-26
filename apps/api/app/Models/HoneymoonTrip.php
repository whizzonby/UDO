<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HoneymoonTrip extends Model
{
    protected $fillable = [
        'wedding_id', 'destination', 'departure_date', 'return_date', 'status',
        'notes', 'checklist',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'return_date' => 'date',
        'checklist' => 'array',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function items(): HasMany { return $this->hasMany(HoneymoonItem::class); }
}
