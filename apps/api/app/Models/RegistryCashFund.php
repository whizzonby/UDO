<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class RegistryCashFund extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id', 'title', 'description',
        'target_amount', 'is_active', 'share_token',
    ];

    protected $casts = [
        'target_amount' => 'decimal:2',
        'is_active'     => 'boolean',
    ];

    protected static function boot(): void
    {
        parent::boot();
        static::creating(function (self $fund) {
            if (empty($fund->share_token)) {
                $fund->share_token = Str::random(32);
            }
        });
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
