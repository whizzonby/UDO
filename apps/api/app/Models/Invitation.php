<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Invitation extends Model
{
    protected $fillable = [
        'wedding_id',
        'title_line',
        'invitation_text',
        'date_text',
        'venue_text',
        'optional_quote',
        'rsvp_deadline_text',
        'cover_image_url',
        'imported_asset_url',
        'imported_asset_type',
        'template_id',
        'theme_id',
        'published_at',
    ];

    protected $casts = [
        'published_at' => 'datetime',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
