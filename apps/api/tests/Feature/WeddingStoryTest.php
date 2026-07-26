<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use App\Services\SmartAlertService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WeddingStoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_phases_bucket_real_data_by_real_dates(): void
    {
        [$owner, $wedding] = $this->userWithWedding(now()->subDays(30));

        // Engagement & Planning — well before wedding week.
        $wedding->tasks()->create(['title' => 'Book florist', 'created_by' => $owner->id, 'completed' => true, 'completed_at' => now()->subDays(60)]);
        $wedding->vendors()->create(['name' => 'Great Cakes', 'category' => 'catering', 'booking_status' => 'confirmed']);
        $wedding->messages()->create([
            'created_by' => $owner->id, 'campaign_name' => 'Invites', 'campaign_type' => 'invitation',
            'message_type' => 'invitation', 'subject' => 'Hi', 'body' => 'Body', 'channel' => 'email',
            'status' => 'sent', 'sent_at' => now()->subDays(50),
        ]);

        // Wedding Week / attending guests.
        $wedding->guests()->create(['first_name' => 'Yes', 'last_name' => 'Guest', 'attending_status' => 'yes']);
        $wedding->guests()->create(['first_name' => 'No', 'last_name' => 'Guest', 'attending_status' => 'no']);
        $wedding->guests()->create(['first_name' => 'Pending', 'last_name' => 'Guest', 'attending_status' => 'pending']);

        // Wedding Day — on the event date itself.
        $wedding->timelineItems()->create(['title' => 'Ceremony', 'event_date' => $wedding->event_date, 'event_type' => 'ceremony']);
        $dayAsset = $wedding->galleryAssets()->create(['type' => 'photo', 'url' => 'https://example.test/a.jpg', 'album' => 'guest_uploads']);
        $dayAsset->created_at = $wedding->event_date;
        $dayAsset->save();

        // Happily Ever After — after the wedding (real "now", already after the seeded event date).
        $wedding->galleryAssets()->create(['type' => 'photo', 'url' => 'https://example.test/b.jpg', 'album' => 'moments']);

        Sanctum::actingAs($owner);
        $response = $this->getJson('/api/wedding-story')->assertOk();

        $phases = collect($response->json('data.phases'))->keyBy('key');

        $this->assertSame(1, $phases['engagement_planning']['stats']['tasks_completed']);
        $this->assertSame(1, $phases['engagement_planning']['stats']['vendors_booked']);
        $this->assertSame(1, $phases['engagement_planning']['stats']['invitations_sent']);

        $this->assertSame(1, $phases['wedding_week']['stats']['attending_guests']);
        $this->assertEqualsWithDelta(66.7, $phases['wedding_week']['stats']['rsvp_completion_rate'], 0.1);

        $this->assertCount(1, $phases['wedding_day']['stats']['timeline_items']);
        $this->assertSame(1, $phases['wedding_day']['stats']['photos']);

        $this->assertSame(1, $phases['happily_ever_after']['stats']['photos_since']);
    }

    public function test_private_vow_hidden_from_non_core_collaborator(): void
    {
        [$owner, $wedding] = $this->userWithWedding(now()->subDays(10));
        $wedding->memoryVows()->create(['title' => 'My private vow', 'draft_text' => 'secret', 'is_private' => true]);
        $wedding->memoryVows()->create(['title' => 'Shared vow', 'draft_text' => 'public', 'is_private' => false]);

        $collaborator = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create(['user_id' => $collaborator->id, 'role' => 'planner', 'status' => 'accepted']);

        Sanctum::actingAs($collaborator);
        $response = $this->getJson('/api/wedding-story')->assertOk();
        $vows = $response->json('data.memories.vows');

        $this->assertCount(1, $vows);
        $this->assertSame('Shared vow', $vows[0]['title']);
    }

    public function test_anniversary_alert_fires_on_the_anniversary_and_unviewed_vows_alert_clears_after_viewing(): void
    {
        // Event date exactly 2 years ago today — same month/day, so the
        // anniversary alert's date math should fire with days_until = 0.
        [$owner, $wedding] = $this->userWithWedding(now()->subYears(2));
        $vow = $wedding->memoryVows()->create(['title' => 'Our vow', 'draft_text' => 'I promise...', 'is_private' => false]);

        Sanctum::actingAs($owner);

        $alerts = app(SmartAlertService::class)->refresh($wedding->fresh());
        $keys = $alerts->pluck('key');

        $this->assertTrue($keys->contains(fn ($key) => str_starts_with($key, 'anniversary-')));
        $this->assertTrue($keys->contains('unviewed-vows'));

        $this->postJson("/api/plan/memories/vows/{$vow->id}/mark-viewed")->assertOk();
        $this->assertNotNull($vow->fresh()->viewed_at);

        $alertsAfterViewing = app(SmartAlertService::class)->refresh($wedding->fresh());
        $this->assertFalse($alertsAfterViewing->pluck('key')->contains('unviewed-vows'));
    }

    public function test_anniversary_alert_does_not_fire_outside_the_window(): void
    {
        [$owner, $wedding] = $this->userWithWedding(now()->subYears(1)->subDays(60));

        $alerts = app(SmartAlertService::class)->refresh($wedding->fresh());

        $this->assertFalse($alerts->pluck('key')->contains(fn ($key) => str_starts_with($key, 'anniversary-')));
    }

    private function userWithWedding($eventDate): array
    {
        $user = User::factory()->create();
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => $user->id,
            'event_date' => $eventDate,
        ]);
        $user->update(['active_wedding_id' => $wedding->id]);

        return [$user->fresh(), $wedding];
    }
}
