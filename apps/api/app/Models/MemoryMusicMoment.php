<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemoryMusicMoment extends Model
{
    protected $fillable = [
        'wedding_id', 'first_dance_song', 'parent_dance_song', 'entrance_music',
        'exit_song', 'cake_cutting_song', 'bouquet_toss_song', 'other_moments',
    ];

    protected $casts = [
        'other_moments' => 'array',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
