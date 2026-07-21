<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SavedFilter extends Model
{
    protected $fillable = [
        'wedding_id',
        'user_id',
        'resource_type',
        'name',
        'criteria',
        'is_default',
    ];

    protected $casts = [
        'criteria' => 'array',
        'is_default' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
