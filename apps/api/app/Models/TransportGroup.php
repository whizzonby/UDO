<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TransportGroup extends Model
{
    protected $fillable = [
        'wedding_id', 'name', 'type', 'pickup_location', 'dropoff_location',
        'departure_time', 'capacity', 'assigned_count',
        'driver_name', 'driver_phone', 'vehicle_registration', 'notes',
    ];

    protected $casts = [
        'departure_time' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function assignments(): HasMany { return $this->hasMany(GuestTransportAssignment::class); }
}
