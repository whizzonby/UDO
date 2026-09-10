<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Coupon extends Model
{
    protected $fillable = [
        'code', 'type', 'value', 'max_redemptions', 'redeemed_count',
        'expires_at', 'status', 'note', 'created_by',
    ];

    protected $casts = [
        'value' => 'integer',
        'max_redemptions' => 'integer',
        'redeemed_count' => 'integer',
        'expires_at' => 'datetime',
    ];

    protected function setCodeAttribute(string $value): void
    {
        $this->attributes['code'] = strtoupper(trim($value));
    }

    public function redemptions(): HasMany
    {
        return $this->hasMany(CouponRedemption::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function isRedeemable(): bool
    {
        if ($this->status !== 'active') {
            return false;
        }

        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }

        if ($this->max_redemptions !== null && $this->redeemed_count >= $this->max_redemptions) {
            return false;
        }

        return true;
    }

    public function discountCents(int $baseCents): int
    {
        $discount = $this->type === 'percent'
            ? (int) round($baseCents * $this->value / 100)
            : $this->value;

        return min($discount, $baseCents);
    }
}
