<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingPartyFile extends Model
{
    protected $fillable = [
        'wedding_id', 'guest_id', 'uploaded_by', 'category', 'name', 'url', 'file_size_bytes',
    ];

    protected $casts = [
        'file_size_bytes' => 'integer',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
    public function uploader(): BelongsTo { return $this->belongsTo(User::class, 'uploaded_by'); }
}
