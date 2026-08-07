<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class AccommodationOption extends Model
{
    protected $fillable = [
        'wedding_id', 'name', 'type', 'address', 'city', 'country',
        'price_per_night', 'currency', 'total_rooms_blocked', 'rooms_assigned',
        'booking_code', 'contact_name', 'contact_phone', 'contact_email',
        'website', 'distance_from_venue_km', 'check_in_date', 'check_out_date', 'notes',
        'room_labels',
    ];

    protected $casts = [
        'price_per_night' => 'decimal:2',
        'distance_from_venue_km' => 'decimal:2',
        'check_in_date' => 'date',
        'check_out_date' => 'date',
        'room_labels' => 'array',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function assignedGuests(): HasMany { return $this->hasMany(Guest::class, 'hotel_assignment_id'); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }
}
