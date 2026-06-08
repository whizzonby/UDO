<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CashFundContribution extends Model
{
    use HasUuids;

    protected $fillable = [
        'cash_fund_id',
        'stripe_session_id',
        'stripe_payment_intent_id',
        'amount',
        'currency',
        'status',
        'contributor_name',
        'contributor_email',
        'message',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
    ];

    public function cashFund(): BelongsTo
    {
        return $this->belongsTo(RegistryCashFund::class, 'cash_fund_id');
    }
}
