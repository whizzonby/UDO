<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OnboardingResponse extends Model
{
    protected $fillable = ['user_id', 'wedding_id', 'responses'];

    protected $casts = [
        'responses' => 'array',
    ];

    public function user(): BelongsTo { return $this->belongsTo(User::class); }
    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
