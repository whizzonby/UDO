<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemorySpeech extends Model
{
    protected $fillable = [
        'wedding_id', 'speaker_name', 'role', 'confirmed', 'duration_minutes',
        'speaking_order', 'notes', 'draft_file_path', 'visibility', 'reminder_date',
    ];

    protected $casts = [
        'confirmed' => 'boolean',
        'duration_minutes' => 'integer',
        'speaking_order' => 'integer',
        'reminder_date' => 'date',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
