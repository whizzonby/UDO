<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RegistryItem extends Model
{
    protected $fillable = [
        'wedding_id', 'type', 'name', 'description', 'image_url',
        'store_name', 'store_url', 'price', 'currency',
        'quantity_requested', 'quantity_purchased',
        'is_priority', 'is_visible', 'fund_goal', 'fund_raised',
        'stripe_payment_link', 'sort_order',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'fund_goal' => 'decimal:2',
        'fund_raised' => 'decimal:2',
        'is_priority' => 'boolean',
        'is_visible' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function contributions(): HasMany { return $this->hasMany(RegistryContribution::class); }
}
