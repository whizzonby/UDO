<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Guest extends Model
{
    protected $fillable = [
        'wedding_id',
        'first_name',
        'last_name',
        'email',
        'phone',
        'guest_group',
        'custom_tags',
        'vip_flag',
        'attending_status',
        'invite_status',
        'plus_one_allowed',
        'plus_one_count',
        'meal_preference',
        'allergies',
        'dietary_note',
        'travel_required',
        'arrival_date',
        'arrival_time',
        'departure_date',
        'departure_time',
        'arrival_airport',
        'hotel_assignment_id',
        'transport_assignment_id',
        'seating_assignment_id',
        'guest_view_type',
        'notes',
    ];

    protected $casts = [
        'custom_tags' => 'array',
        'vip_flag' => 'boolean',
        'plus_one_allowed' => 'boolean',
        'travel_required' => 'boolean',
        'arrival_date' => 'date',
        'departure_date' => 'date',
    ];

    public function getFullNameAttribute(): string
    {
        return trim($this->first_name . ' ' . $this->last_name);
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function token(): HasOne
    {
        return $this->hasOne(GuestToken::class);
    }
}
