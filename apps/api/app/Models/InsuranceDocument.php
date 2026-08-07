<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InsuranceDocument extends Model
{
    protected $fillable = [
        'wedding_id', 'uploaded_by', 'name', 'url', 'file_size_bytes',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function uploader(): BelongsTo { return $this->belongsTo(User::class, 'uploaded_by'); }
}
