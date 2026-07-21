<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class SupportTicket extends Model
{
    protected $fillable = [
        'user_id', 'wedding_id', 'reference', 'subject', 'body', 'status', 'priority',
        'channel', 'admin_notes', 'assigned_to', 'first_responded_at', 'resolved_at',
    ];

    protected $casts = [
        'first_responded_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (SupportTicket $ticket) {
            if (empty($ticket->reference)) {
                $ticket->reference = 'UDO-' . str_pad(random_int(1, 999999), 6, '0', STR_PAD_LEFT);
            }
        });

        static::updating(function (SupportTicket $ticket) {
            if (! $ticket->isDirty('status')) {
                return;
            }

            if ($ticket->status !== 'open' && ! $ticket->first_responded_at) {
                $ticket->first_responded_at = now();
            }

            if (in_array($ticket->status, ['resolved', 'closed'], true)) {
                $ticket->resolved_at ??= now();
            } else {
                $ticket->resolved_at = null;
            }
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function assignee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }
}
