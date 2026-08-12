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
        'slug', 'invite_code', 'title', 'couple_name_primary', 'couple_name_secondary',
        'event_date', 'timezone', 'city', 'country', 'primary_venue_name',
        'primary_venue_address', 'venue_place_id', 'cover_photo_path', 'couple_photo_path', 'hashtag', 'gallery_upload_token', 'venue_lat', 'venue_lng', 'rsvp_deadline', 'status', 'owner_user_id', 'settings', 'vision_style',
        'pinterest_access_token', 'pinterest_refresh_token', 'pinterest_token_expires_at', 'pinterest_username',
    ];

    protected $casts = [
        'event_date' => 'date',
        'rsvp_deadline' => 'date',
        'settings' => 'array',
        'vision_style' => 'array',
        'venue_lat' => 'decimal:7',
        'venue_lng' => 'decimal:7',
        'pinterest_access_token' => 'encrypted',
        'pinterest_refresh_token' => 'encrypted',
        'pinterest_token_expires_at' => 'datetime',
    ];

    protected static function booted(): void
    {
        static::creating(function (Wedding $wedding) {
            if (empty($wedding->slug)) {
                $wedding->slug = Str::slug($wedding->couple_name_primary . '-' . now()->year) . '-' . Str::random(6);
            }
            if (empty($wedding->invite_code)) {
                do {
                    $code = strtoupper(Str::random(6));
                } while (static::where('invite_code', $code)->exists());
                $wedding->invite_code = $code;
            }
        });
    }

    public function ensureGalleryUploadToken(): string
    {
        if (empty($this->gallery_upload_token)) {
            $this->gallery_upload_token = Str::random(48);
            $this->save();
        }
        return $this->gallery_upload_token;
    }

    public function owner(): BelongsTo { return $this->belongsTo(User::class, 'owner_user_id'); }
    public function collaborators(): HasMany { return $this->hasMany(WeddingCollaborator::class); }
    public function guests(): HasMany { return $this->hasMany(Guest::class); }
    public function invitation(): HasOne { return $this->hasOne(Invitation::class); }
    public function guestTokens(): HasMany { return $this->hasMany(GuestToken::class); }
    public function tasks(): HasMany { return $this->hasMany(Task::class); }
    public function timelineItems(): HasMany { return $this->hasMany(TimelineItem::class)->orderBy('event_date')->orderBy('start_time'); }
    public function budgetItems(): HasMany { return $this->hasMany(BudgetItem::class); }
    public function aiAssistantLogs(): HasMany { return $this->hasMany(AiAssistantLog::class); }
    public function budgetPaymentSchedules(): HasMany { return $this->hasMany(BudgetPaymentSchedule::class)->orderBy('due_date'); }
    public function vendors(): HasMany { return $this->hasMany(Vendor::class); }
    public function messages(): HasMany { return $this->hasMany(Message::class); }
    public function moodCheckins(): HasMany { return $this->hasMany(MoodCheckin::class); }
    public function menuCourses(): HasMany { return $this->hasMany(MenuCourse::class)->orderBy('sort_order'); }
    public function foodServiceItems(): HasMany { return $this->hasMany(FoodServiceItem::class)->orderBy('event_date')->orderBy('start_time'); }
    public function accommodationOptions(): HasMany { return $this->hasMany(AccommodationOption::class); }
    public function transportGroups(): HasMany { return $this->hasMany(TransportGroup::class); }
    public function seatingTables(): HasMany { return $this->hasMany(SeatingTable::class)->orderBy('sort_order'); }
    public function guestPairings(): HasMany { return $this->hasMany(GuestPairing::class); }
    public function liveUpdates(): HasMany { return $this->hasMany(LiveUpdate::class)->latest(); }
    public function galleryAlbums(): HasMany { return $this->hasMany(GalleryAlbum::class); }
    public function galleryAssets(): HasMany { return $this->hasMany(GalleryAsset::class)->latest(); }
    public function auditLogs(): HasMany { return $this->hasMany(AuditLog::class)->latest(); }
    public function smartAlerts(): HasMany { return $this->hasMany(SmartAlert::class)->latest('trigger_at')->latest(); }
    public function savedFilters(): HasMany { return $this->hasMany(SavedFilter::class); }
    public function registryItems(): HasMany { return $this->hasMany(RegistryItem::class)->orderBy('sort_order'); }
    public function thankYouRecords(): HasMany { return $this->hasMany(ThankYouRecord::class); }
    public function experienceConfig(): HasOne { return $this->hasOne(GuestExperienceConfig::class); }
    public function weddingPartyResponsibilities(): HasMany { return $this->hasMany(WeddingPartyResponsibility::class)->orderBy('sort_order'); }
    public function weddingPartyEmergencyContacts(): HasMany { return $this->hasMany(WeddingPartyEmergencyContact::class)->orderBy('sort_order'); }
    public function weddingPartyFiles(): HasMany { return $this->hasMany(WeddingPartyFile::class)->latest(); }
    public function supportTickets(): HasMany { return $this->hasMany(SupportTicket::class)->latest(); }
    public function reminders(): HasMany { return $this->hasMany(Reminder::class)->orderBy('due_date'); }
    public function insurancePolicies(): HasMany { return $this->hasMany(InsurancePolicy::class); }
    public function insuranceDocuments(): HasMany { return $this->hasMany(InsuranceDocument::class)->latest(); }
    public function weddingDocuments(): HasMany { return $this->hasMany(WeddingDocument::class)->latest(); }
    public function weddingWeekendEvents(): HasMany { return $this->hasMany(WeddingWeekendEvent::class)->orderBy('event_date')->orderBy('start_time'); }
    public function rehearsals(): HasMany { return $this->hasMany(Rehearsal::class)->orderBy('event_date')->orderBy('start_time'); }
    public function honeymoonTrip(): HasOne { return $this->hasOne(HoneymoonTrip::class); }
    public function memorySpeeches(): HasMany { return $this->hasMany(MemorySpeech::class)->orderBy('speaking_order'); }
    public function memoryVows(): HasMany { return $this->hasMany(MemoryVow::class); }
    public function memoryTraditions(): HasMany { return $this->hasMany(MemoryTradition::class); }
    public function memoryGuestbook(): HasOne { return $this->hasOne(MemoryGuestbook::class); }
    public function memoryPhotoBooth(): HasOne { return $this->hasOne(MemoryPhotoBooth::class); }
    public function memoryMusicMoment(): HasOne { return $this->hasOne(MemoryMusicMoment::class); }
    public function approvalRequests(): HasMany { return $this->hasMany(ApprovalRequest::class)->latest(); }
}
