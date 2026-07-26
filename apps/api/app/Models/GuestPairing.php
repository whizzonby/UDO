<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestPairing extends Model
{
    protected $fillable = ['wedding_id', 'guest_id', 'related_guest_id', 'type'];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
    public function relatedGuest(): BelongsTo { return $this->belongsTo(Guest::class, 'related_guest_id'); }
}
