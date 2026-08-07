<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HoneymoonItem extends Model
{
    protected $fillable = [
        'honeymoon_trip_id', 'type', 'status', 'title', 'date', 'time', 'cost',
        'budget_item_id', 'traveler_ids', 'details',
    ];

    protected $casts = [
        'date' => 'date',
        'cost' => 'decimal:2',
        'traveler_ids' => 'array',
        'details' => 'array',
    ];

    public function trip(): BelongsTo { return $this->belongsTo(HoneymoonTrip::class, 'honeymoon_trip_id'); }
    public function budgetItem(): BelongsTo { return $this->belongsTo(BudgetItem::class); }
}
