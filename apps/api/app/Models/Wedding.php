<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Str;

class Wedding extends Model
{
    protected $fillable = [
        'slug', 'title', 'couple_name_primary', 'couple_name_secondary',
        'event_date', 'timezone', 'city', 'country', 'primary_venue_name',
        'primary_venue_address', 'rsvp_deadline', 'status', 'owner_user_id', 'settings',
    ];

    protected $casts = [
        'event_date' => 'date',
        'rsvp_deadline' => 'date',
        'settings' => 'array',
    ];

    protected static function booted(): void
    {
        static::creating(function (Wedding $wedding) {
            if (empty($wedding->slug)) {
                $wedding->slug = Str::slug($wedding->couple_name_primary . '-' . now()->year) . '-' . Str::random(6);
            }
        });
    }

    public function owner(): BelongsTo { return $this->belongsTo(User::class, 'owner_user_id'); }
    public function collaborators(): HasMany { return $this->hasMany(WeddingCollaborator::class); }
    public function guests(): HasMany { return $this->hasMany(Guest::class); }
    public function invitation(): HasOne { return $this->hasOne(Invitation::class); }
    public function guestTokens(): HasMany { return $this->hasMany(GuestToken::class); }
    public function tasks(): HasMany { return $this->hasMany(Task::class); }
    public function timelineItems(): HasMany { return $this->hasMany(TimelineItem::class)->orderBy('event_date')->orderBy('start_time'); }
    public function budgetItems(): HasMany { return $this->hasMany(BudgetItem::class); }
    public function vendors(): HasMany { return $this->hasMany(Vendor::class); }
    public function messages(): HasMany { return $this->hasMany(Message::class); }
    public function accommodationOptions(): HasMany { return $this->hasMany(AccommodationOption::class); }
    public function transportGroups(): HasMany { return $this->hasMany(TransportGroup::class); }
    public function seatingTables(): HasMany { return $this->hasMany(SeatingTable::class)->orderBy('sort_order'); }
    public function liveUpdates(): HasMany { return $this->hasMany(LiveUpdate::class)->latest(); }
    public function galleryAssets(): HasMany { return $this->hasMany(GalleryAsset::class)->latest(); }
    public function registryItems(): HasMany { return $this->hasMany(RegistryItem::class)->orderBy('sort_order'); }
    public function experienceConfig(): HasOne { return $this->hasOne(GuestExperienceConfig::class); }
}
