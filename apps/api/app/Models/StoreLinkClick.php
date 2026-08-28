<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StoreLinkClick extends Model
{
    /** Clicks are immutable — created_at only. */
    public const UPDATED_AT = null;

    protected $fillable = [
        'platform',
        'source_path',
        'link_location',
        'utm_source',
        'utm_medium',
        'utm_campaign',
        'utm_content',
        'utm_term',
        'referrer',
        'country',
        'ip_hash',
        'user_agent',
        'click_id',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];
}
