<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GuestMenuSelection extends Model
{
    protected $fillable = ['guest_id', 'menu_course_id', 'menu_course_option_id', 'wedding_id'];

    public function guest(): BelongsTo
    {
        return $this->belongsTo(Guest::class);
    }

    public function course(): BelongsTo
    {
        return $this->belongsTo(MenuCourse::class, 'menu_course_id');
    }

    public function option(): BelongsTo
    {
        return $this->belongsTo(MenuCourseOption::class, 'menu_course_option_id');
    }
}
