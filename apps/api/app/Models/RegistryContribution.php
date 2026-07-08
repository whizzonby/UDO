<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegistryContribution extends Model
{
    protected $fillable = [
        'registry_item_id', 'wedding_id', 'guest_id',
        'contributor_name', 'contributor_email', 'amount', 'quantity',
        'stripe_payment_intent_id', 'payment_status', 'message',
        'thank_you_sent', 'paid_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'thank_you_sent' => 'boolean',
        'paid_at' => 'datetime',
    ];

    public function item(): BelongsTo { return $this->belongsTo(RegistryItem::class, 'registry_item_id'); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
}
