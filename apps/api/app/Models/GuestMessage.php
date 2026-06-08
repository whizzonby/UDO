<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestMessage extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id',
        'subject',
        'body',
        'channel',
        'recipient_filter',
        'recipient_count',
        'status',
        'sent_at',
    ];

    protected $casts = [
        'recipient_filter' => 'array',
        'sent_at'          => 'datetime',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
