<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class GuestToken extends Model
{
    protected $fillable = [
        'wedding_id',
        'guest_id',
        'token',
        'view_type',
        'revoked',
        'expires_at',
    ];

    protected $casts = [
        'revoked' => 'boolean',
        'expires_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (GuestToken $guestToken) {
            if (empty($guestToken->token)) {
                $guestToken->token = Str::random(48);
            }
            if (empty($guestToken->expires_at)) {
                $guestToken->expires_at = now()->addDays((int) config('services.guest_tokens.default_expiry_days', 365));
            }
        });
    }

    public function isValid(): bool
    {
        if ($this->revoked) {
            return false;
        }
        if ($this->expires_at && $this->expires_at->isPast()) {
            return false;
        }
        return true;
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function guest(): BelongsTo
    {
        return $this->belongsTo(Guest::class);
    }
}
