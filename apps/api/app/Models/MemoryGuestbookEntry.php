<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemoryGuestbookEntry extends Model
{
    protected $fillable = [
        'memory_guestbook_id', 'guest_id', 'guest_name', 'message', 'approved',
    ];

    protected $casts = [
        'approved' => 'boolean',
    ];

    public function guestbook(): BelongsTo { return $this->belongsTo(MemoryGuestbook::class, 'memory_guestbook_id'); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
