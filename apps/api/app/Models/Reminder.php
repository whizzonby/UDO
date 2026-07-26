<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Reminder extends Model
{
    protected $fillable = [
        'wedding_id', 'title', 'description', 'due_date', 'priority', 'status',
        'source', 'source_key', 'source_description',
    ];

    protected $casts = [
        'due_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
