<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SeatingTable extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id', 'name', 'capacity', 'shape', 'section', 'color', 'sort_order',
    ];

    protected $casts = [
        'capacity'   => 'integer',
        'sort_order' => 'integer',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function assignments(): HasMany
    {
        return $this->hasMany(TableAssignment::class, 'table_id');
    }
}
