<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingPartyResponsibility extends Model
{
    protected $fillable = [
        'wedding_id', 'guest_id', 'title', 'description', 'status', 'priority', 'due_date', 'sort_order',
    ];

    protected $casts = [
        'due_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
