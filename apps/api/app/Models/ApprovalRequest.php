<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class ApprovalRequest extends Model
{
    protected $fillable = [
        'wedding_id', 'category', 'subject_type', 'subject_id', 'action',
        'title', 'description', 'requested_by', 'payload', 'status', 'resolved_at',
    ];

    protected $casts = [
        'payload' => 'array',
        'resolved_at' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function requester(): BelongsTo { return $this->belongsTo(User::class, 'requested_by'); }
    public function subject(): MorphTo { return $this->morphTo(); }
    public function votes(): HasMany { return $this->hasMany(ApprovalRequestVote::class); }
}
