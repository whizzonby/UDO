<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class Subscription extends Model
{
    protected $fillable = [
        'user_id', 'plan', 'status', 'billing_cycle', 'amount', 'currency',
        'stripe_customer_id', 'stripe_subscription_id', 'stripe_price_id',
        'trial_ends_at', 'current_period_start', 'current_period_end',
        'cancelled_at', 'ends_at', 'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'trial_ends_at' => 'datetime',
        'current_period_start' => 'datetime',
        'current_period_end' => 'datetime',
        'cancelled_at' => 'datetime',
        'ends_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function subjectAuditLogs(): MorphMany
    {
        return $this->morphMany(AuditLog::class, 'auditable');
    }

    public function isActive(): bool
    {
        return in_array($this->status, ['active', 'trialing']);
    }

    public function getPlanLabelAttribute(): string
    {
        return match ($this->plan) {
            'starter' => 'Starter',
            'pro' => 'Pro',
            'elite' => 'Elite',
            default => 'Free',
        };
    }
}
