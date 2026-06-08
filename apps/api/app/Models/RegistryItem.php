<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RegistryItem extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id', 'title', 'description', 'price', 'url',
        'image_url', 'category', 'is_claimed', 'claimed_by_name',
        'thank_you_sent', 'sort_order',
    ];

    protected $casts = [
        'price'         => 'decimal:2',
        'is_claimed'    => 'boolean',
        'thank_you_sent'=> 'boolean',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
