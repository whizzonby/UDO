<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InsurancePolicy extends Model
{
    protected $fillable = [
        'wedding_id', 'provider', 'policy_number', 'policy_type', 'coverage_amount',
        'premium', 'deductible', 'purchase_date', 'start_date', 'end_date',
        'status', 'contact_number', 'notes',
    ];

    protected $casts = [
        'coverage_amount' => 'decimal:2',
        'premium' => 'decimal:2',
        'deductible' => 'decimal:2',
        'purchase_date' => 'date',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
