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
        'relationship',
        'age_group',
        'is_vip',
        'dietary_requirements',
        'plus_one_allowed',
        'plus_one_name',
        'plus_one_rsvp_attending',
        'invitation_sent_at',
        'rsvp_responded_at',
        'checked_in_at',
        'address',
        'language',
        'needs_transport',
        'needs_accommodation',
        'is_child',
        'sort_order',
        'token',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'is_vip'                   => 'boolean',
            'plus_one_allowed'         => 'boolean',
            'plus_one_rsvp_attending'  => 'boolean',
            'needs_transport'          => 'boolean',
            'needs_accommodation'      => 'boolean',
            'is_child'                 => 'boolean',
            'invitation_sent_at'       => 'datetime',
            'rsvp_responded_at'        => 'datetime',
            'checked_in_at'            => 'datetime',
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
