<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HoneymoonTrip extends Model
{
    protected $fillable = [
        'wedding_id', 'destination', 'cover_photo_path', 'departure_date', 'return_date',
        'total_budget', 'status', 'notes', 'checklist', 'dress_code', 'packing_notes',
    ];

    protected $casts = [
        'departure_date' => 'date',
        'return_date' => 'date',
        'total_budget' => 'decimal:2',
        'checklist' => 'array',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function items(): HasMany { return $this->hasMany(HoneymoonItem::class); }
    public function travelers(): HasMany { return $this->hasMany(HoneymoonTraveler::class); }
}
