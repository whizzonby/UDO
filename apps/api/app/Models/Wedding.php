<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Wedding extends Model
{
    use HasFactory, HasUuids;

    protected $fillable = [
        'partner_one_name',
        'partner_two_name',
        'wedding_date',
        'date_not_set',
        'venue_name',
        'venue_address',
        'venue_city',
        'guest_count_range',
        'currency',
        'total_budget',
        'cover_photo_url',
        'status',
        'timezone',
        'settings',
    ];

    protected function casts(): array
    {
        return [
            'wedding_date' => 'date',
            'date_not_set' => 'boolean',
            'total_budget' => 'decimal:2',
            'settings' => 'array',
        ];
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'wedding_users')
            ->withPivot(['role', 'permissions', 'joined_at'])
            ->withTimestamps();
    }

    public function onboardingData(): HasOne
    {
        return $this->hasOne(OnboardingData::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class)->orderBy('sort_order');
    }

    public function timelineEvents(): HasMany
    {
        return $this->hasMany(TimelineEvent::class)->orderBy('event_date')->orderBy('sort_order');
    }

    public function vendors(): HasMany
    {
        return $this->hasMany(Vendor::class);
    }

    public function budgetItems(): HasMany
    {
        return $this->hasMany(BudgetItem::class);
    }

    public function guests(): HasMany
    {
        return $this->hasMany(Guest::class);
    }

    public function experienceConfig(): HasOne
    {
        return $this->hasOne(WeddingExperienceConfig::class);
    }
}
