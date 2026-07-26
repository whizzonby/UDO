<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Guest extends Model
{
    protected $fillable = [
        'wedding_id',
        'first_name',
        'last_name',
        'email',
        'email_opt_out',
        'phone',
        'sms_opt_out',
        'whatsapp_opt_out',
        'communication_preferences_updated_at',
        'guest_group',
        'custom_tags',
        'vip_flag',
        'is_elderly',
        'accessibility_needs',
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
        'checked_in_at',
        'arrival_airport',
        'hotel_assignment_id',
        'transport_assignment_id',
        'seating_assignment_id',
        'guest_view_type',
        'notes',
        'wedding_party_role',
        'attire_status',
        'rehearsal_status',
    ];

    protected $casts = [
        'custom_tags' => 'array',
        'vip_flag' => 'boolean',
        'is_elderly' => 'boolean',
        'accessibility_needs' => 'boolean',
        'plus_one_allowed' => 'boolean',
        'travel_required' => 'boolean',
        'email_opt_out' => 'boolean',
        'sms_opt_out' => 'boolean',
        'whatsapp_opt_out' => 'boolean',
        'arrival_date' => 'date',
        'departure_date' => 'date',
        'checked_in_at' => 'datetime',
        'communication_preferences_updated_at' => 'datetime',
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

    public function menuSelections(): HasMany
    {
        return $this->hasMany(GuestMenuSelection::class);
    }
}
