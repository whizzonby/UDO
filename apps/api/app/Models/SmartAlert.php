<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SmartAlert extends Model
{
    protected $fillable = [
        'wedding_id',
        'key',
        'alert_type',
        'severity',
        'status',
        'target',
        'title',
        'body',
        'action_label',
        'action_url',
        'trigger_at',
        'resolved_at',
        'metadata',
    ];

    protected $casts = [
        'trigger_at' => 'datetime',
        'resolved_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
