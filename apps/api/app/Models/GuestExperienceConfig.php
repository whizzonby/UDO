<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestExperienceConfig extends Model
{
    protected $fillable = [
        'wedding_id', 'show_schedule', 'show_venue_map', 'show_accommodation',
        'show_transport', 'show_dress_code', 'show_registry', 'show_gallery',
        'show_live_feed', 'allow_photo_uploads', 'allow_messages',
        'welcome_message', 'dress_code', 'dress_code_details',
        'cover_image_url', 'theme_color',
        'rsvp_enabled', 'meal_selection_enabled', 'plus_one_enabled',
    ];

    protected $casts = [
        'show_schedule' => 'boolean', 'show_venue_map' => 'boolean',
        'show_accommodation' => 'boolean', 'show_transport' => 'boolean',
        'show_dress_code' => 'boolean', 'show_registry' => 'boolean',
        'show_gallery' => 'boolean', 'show_live_feed' => 'boolean',
        'allow_photo_uploads' => 'boolean', 'allow_messages' => 'boolean',
        'rsvp_enabled' => 'boolean', 'meal_selection_enabled' => 'boolean',
        'plus_one_enabled' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
}
