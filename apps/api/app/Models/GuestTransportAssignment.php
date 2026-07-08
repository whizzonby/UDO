<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestTransportAssignment extends Model
{
    protected $fillable = ['transport_group_id', 'guest_id', 'wedding_id', 'notes'];

    public function transportGroup(): BelongsTo { return $this->belongsTo(TransportGroup::class); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
