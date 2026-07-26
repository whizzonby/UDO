<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemoryTradition extends Model
{
    protected $fillable = [
        'wedding_id', 'name', 'description', 'person_responsible', 'required_items',
        'timing', 'location', 'notes', 'visibility',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
