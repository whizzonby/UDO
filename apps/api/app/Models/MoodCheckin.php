<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MoodCheckin extends Model
{
    public $timestamps = false;

    protected $fillable = ['wedding_id', 'user_id', 'mood', 'created_at'];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
