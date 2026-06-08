<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vendor extends Model
{
    use HasFactory;

    protected $fillable = [
        'wedding_id',
        'category',
        'name',
        'contact_name',
        'contact_email',
        'contact_phone',
        'website',
        'status',
        'contract_amount',
        'deposit_amount',
        'deposit_due_date',
        'deposit_paid_at',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'contract_amount' => 'decimal:2',
            'deposit_amount' => 'decimal:2',
            'deposit_due_date' => 'date',
            'deposit_paid_at' => 'datetime',
        ];
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function budgetItems(): HasMany
    {
        return $this->hasMany(BudgetItem::class);
    }
}
