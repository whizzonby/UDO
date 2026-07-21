<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class LiveUpdate extends Model
{
    protected $fillable = [
        'wedding_id', 'created_by', 'type', 'title', 'body',
        'severity', 'audience', 'status', 'image_url', 'pinned',
        'visible_to_guests', 'bride_only', 'requires_action', 'event_time', 'resolved_at',
    ];

    protected $casts = [
        'pinned' => 'boolean',
        'visible_to_guests' => 'boolean',
        'bride_only' => 'boolean',
        'requires_action' => 'boolean',
        'event_time' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function creator(): BelongsTo { return $this->belongsTo(User::class, 'created_by'); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }
}
