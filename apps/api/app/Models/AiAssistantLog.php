<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiAssistantLog extends Model
{
    protected $fillable = [
        'wedding_id', 'user_id', 'prompt', 'response',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
