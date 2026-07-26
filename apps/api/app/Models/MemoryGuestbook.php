<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MemoryGuestbook extends Model
{
    protected $fillable = [
        'wedding_id', 'type', 'vendor_name', 'setup_location', 'instructions',
        'status', 'digital_enabled',
    ];

    protected $casts = [
        'digital_enabled' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function entries(): HasMany { return $this->hasMany(MemoryGuestbookEntry::class)->latest(); }
}
