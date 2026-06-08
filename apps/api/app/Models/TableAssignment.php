<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TableAssignment extends Model
{
    use HasUuids;

    protected $fillable = ['table_id', 'guest_id', 'seat_number'];

    protected $casts = ['seat_number' => 'integer'];

    public function seatingTable(): BelongsTo
    {
        return $this->belongsTo(SeatingTable::class, 'table_id');
    }

    public function guest(): BelongsTo
    {
        return $this->belongsTo(Guest::class);
    }
}
