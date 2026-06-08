<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Guest extends Model
{
    use HasFactory;

    protected $fillable = [
        'wedding_id',
        'first_name',
        'last_name',
        'email',
        'phone',
        'rsvp_status',
        'group',
        'is_vip',
        'dietary_requirements',
        'plus_one_allowed',
        'plus_one_name',
        'token',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'is_vip' => 'boolean',
            'plus_one_allowed' => 'boolean',
        ];
    }

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Guest $guest) {
            if (empty($guest->token)) {
                $guest->token = Str::random(32);
            }
        });
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function getFullNameAttribute(): string
    {
        return trim("{$this->first_name} {$this->last_name}");
    }
}
