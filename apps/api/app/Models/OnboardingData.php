<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OnboardingData extends Model
{
    use HasFactory;

    protected $fillable = [
        'wedding_id',
        'user_role',
        'planning_approach',
        'decision_style',
        'planning_stage',
        'wedding_type',
        'season',
        'date_flexibility',
        'time_of_day',
        'event_structures',
        'venue_status',
        'guest_travel_profile',
        'support_needed',
        'food_experience',
        'dietary_needs',
        'entertainment',
        'speeches_config',
        'wedding_insurance',
        'guest_count_range',
        'guest_experience_style',
        'communication_style',
        'invitation_channels',
        'planning_priorities',
        'wedding_vibes',
        'budget_range',
        'completed_at',
    ];

    protected function casts(): array
    {
        return [
            'event_structures' => 'array',
            'support_needed' => 'array',
            'food_experience' => 'array',
            'dietary_needs' => 'array',
            'entertainment' => 'array',
            'speeches_config' => 'array',
            'invitation_channels' => 'array',
            'planning_priorities' => 'array',
            'wedding_vibes' => 'array',
            'completed_at' => 'datetime',
        ];
    }

    public function wedding(): BelongsTo
    {
        return $this->belongsTo(Wedding::class);
    }
}
