<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BudgetItem extends Model
{
    protected $fillable = [
        'wedding_id', 'vendor_id', 'category', 'name',
        'estimated_amount', 'actual_amount', 'paid_amount',
        'due_date', 'payment_status', 'notes', 'is_essential',
    ];

    protected $casts = [
        'due_date' => 'date',
        'estimated_amount' => 'decimal:2',
        'actual_amount' => 'decimal:2',
        'paid_amount' => 'decimal:2',
        'is_essential' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function vendor(): BelongsTo { return $this->belongsTo(Vendor::class); }
    public function paymentSchedules(): HasMany { return $this->hasMany(BudgetPaymentSchedule::class)->orderBy('due_date'); }
}
