<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Testimonial extends Model
{
    protected $fillable = [
        'wedding_id', 'couple_names', 'wedding_date', 'location',
        'quote', 'photo_url', 'rating', 'approved', 'featured', 'sort_order',
    ];

    protected $casts = [
        'wedding_date' => 'date',
        'approved' => 'boolean',
        'featured' => 'boolean',
        'rating' => 'integer',
        'sort_order' => 'integer',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
