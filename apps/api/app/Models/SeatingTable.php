<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SeatingTable extends Model
{
    protected $fillable = [
        'wedding_id', 'name', 'shape', 'capacity', 'assigned_count',
        'pos_x', 'pos_y', 'event_section', 'notes', 'sort_order',
    ];

    protected $casts = [
        'pos_x' => 'decimal:2',
        'pos_y' => 'decimal:2',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function seats(): HasMany { return $this->hasMany(SeatingSeat::class); }
}
