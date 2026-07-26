<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MenuCourseOption extends Model
{
    protected $fillable = ['menu_course_id', 'wedding_id', 'name', 'description', 'dietary_tags', 'confirmed', 'sort_order'];

    protected $casts = [
        'dietary_tags' => 'array',
        'confirmed' => 'boolean',
    ];

    public function course(): BelongsTo
    {
        return $this->belongsTo(MenuCourse::class, 'menu_course_id');
    }

    public function selections(): HasMany
    {
        return $this->hasMany(GuestMenuSelection::class);
    }
}
