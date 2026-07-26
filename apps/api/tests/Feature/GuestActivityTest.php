<?php

namespace Tests\Feature;

use App\Models\AccommodationOption;
use App\Models\GuestToken;
use App\Models\TransportGroup;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GuestActivityTest extends TestCase
{
    use RefreshDatabase;

    public function test_rsvp_submission_creates_a_real_audit_row(): void
    {
        [, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Sarah', 'last_name' => 'Brown']);
        $token = GuestToken::create(['wedding_id' => $wedding->id, 'guest_id' => $guest->id, 'view_type' => 'attending']);
        $wedding->experienceConfig()->create(['publish_state' => 'published', 'rsvp_enabled' => true]);

        $this->postJson("/api/g/{$token->token}/rsvp", ['attending_status' => 'yes'])->assertOk();

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'guest.rsvp_submitted',
            'auditable_type' => \App\Models\Guest::class,
            'auditable_id' => $guest->id,
        ]);
    }

    public function test_hotel_assignment_creates_a_real_audit_row(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $guest = $wedding->guests()->create(['first_name' => 'Michael', 'last_name' => 'Johnson', 'travel_required' => true]);
        $hotel = AccommodationOption::create(['wedding_id' => $wedding->id, 'name' => 'Hyatt Ziva', 'type' => 'hotel']);

        $this->postJson("/api/logistics/accommodation/{$hotel->id}/assign", ['guest_id' => $guest->id])->assertOk();

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'guest.hotel_assigned',
            'auditable_id' => $guest->id,
        ]);
    }

    public function test_transport_assignment_creates_a_real_audit_row(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $guest = $wedding->guests()->create(['first_name' => 'David', 'last_name' => 'Kim', 'travel_required' => true]);
        $group = TransportGroup::create(['wedding_id' => $wedding->id, 'name' => 'Airport Shuttle A', 'type' => 'shuttle']);

        $this->postJson("/api/logistics/transport/{$group->id}/assign", ['guest_id' => $guest->id])->assertOk();

        $this->assertDatabaseHas('audit_logs', [
            'wedding_id' => $wedding->id,
            'action' => 'guest.transport_assigned',
            'auditable_id' => $guest->id,
        ]);
    }

    public function test_activity_feed_returns_real_wedding_scoped_events(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $guest = $wedding->guests()->create(['first_name' => 'Emma', 'last_name' => 'Williams']);
        $token = GuestToken::create(['wedding_id' => $wedding->id, 'guest_id' => $guest->id, 'view_type' => 'attending']);
        $wedding->experienceConfig()->create(['publish_state' => 'published', 'rsvp_enabled' => true]);
        $this->postJson("/api/g/{$token->token}/rsvp", ['attending_status' => 'yes'])->assertOk();

        $this->getJson('/api/guests/activity')
            ->assertOk()
            ->assertJsonPath('data.0.guest_name', 'Emma Williams')
            ->assertJsonPath('data.0.action', 'guest.rsvp_submitted')
            ->assertJsonPath('data.0.label', 'submitted their RSVP');
    }

    public function test_guest_activity_endpoint_returns_activity_and_communications_and_rejects_other_weddings(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $guest = $wedding->guests()->create(['first_name' => 'Sarah', 'last_name' => 'Brown']);
        $token = GuestToken::create(['wedding_id' => $wedding->id, 'guest_id' => $guest->id, 'view_type' => 'attending']);
        $wedding->experienceConfig()->create(['publish_state' => 'published', 'rsvp_enabled' => true]);
        $this->postJson("/api/g/{$token->token}/rsvp", ['attending_status' => 'yes'])->assertOk();

        $this->getJson("/api/guests/{$guest->id}/activity")
            ->assertOk()
            ->assertJsonPath('data.activity.0.action', 'guest.rsvp_submitted')
            ->assertJsonPath('data.communications', []);

        [, $otherWedding] = $this->userWithWedding();
        $otherGuest = $otherWedding->guests()->create(['first_name' => 'Someone Else']);
        $this->getJson("/api/guests/{$otherGuest->id}/activity")->assertStatus(403);
    }

    private function userWithWedding(): array
    {
        $user = User::factory()->create();
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => $user->id,
        ]);
        $user->update(['active_wedding_id' => $wedding->id]);

        return [$user->fresh(), $wedding];
    }
}
