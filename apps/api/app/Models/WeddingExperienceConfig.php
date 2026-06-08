<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WeddingExperienceConfig extends Model
{
    use HasUuids;

    protected $fillable = [
        'wedding_id',
        'is_published',
        'welcome_message',
        'sections_enabled',
        'theme_accent_color',
        'custom_domain',
    ];

    protected $casts = [
        'is_published'     => 'boolean',
        'sections_enabled' => 'array',
    ];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public static function defaultSections(): array
    {
        return [
            'rsvp'          => true,
            'schedule'      => true,
            'venue'         => true,
            'gallery'       => true,
            'registry'      => true,
            'photo_upload'  => true,
        ];
    }
}
