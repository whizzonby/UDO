<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SeatingSeat extends Model
{
    protected $fillable = ['seating_table_id', 'wedding_id', 'guest_id', 'seat_number', 'label'];

    public function table(): BelongsTo { return $this->belongsTo(SeatingTable::class, 'seating_table_id'); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
