<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MenuCourse extends Model
{
    protected $fillable = ['wedding_id', 'name', 'type', 'sort_order'];

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }

    public function options(): HasMany
    {
        return $this->hasMany(MenuCourseOption::class)->orderBy('sort_order');
    }

    public function selections(): HasMany
    {
        return $this->hasMany(GuestMenuSelection::class);
    }
}
