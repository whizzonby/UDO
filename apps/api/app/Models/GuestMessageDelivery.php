<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestMessageDelivery extends Model
{
    protected $fillable = [
        'message_id', 'guest_id', 'status', 'channel', 'external_id',
        'sent_at', 'delivered_at', 'opened_at', 'error_message',
    ];

    protected $casts = [
        'sent_at' => 'datetime',
        'delivered_at' => 'datetime',
        'opened_at' => 'datetime',
    ];

    public function message(): BelongsTo { return $this->belongsTo(Message::class); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
