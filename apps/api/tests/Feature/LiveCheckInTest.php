<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class LiveCheckInTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_can_be_checked_in_and_appears_in_live_today(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create([
            'first_name' => 'Sarah',
            'last_name' => 'Brown',
            'travel_required' => true,
            'arrival_date' => now()->toDateString(),
            'arrival_time' => '14:00',
        ]);

        Sanctum::actingAs($owner);

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.arrivals.arriving_today', 1)
            ->assertJsonPath('data.arrivals.checked_in_count', 0)
            ->assertJsonPath('data.arrivals.arriving_today_guests.0.id', $guest->id)
            ->assertJsonPath('data.arrivals.arriving_today_guests.0.checked_in_at', null);

        $this->patchJson("/api/guests/{$guest->id}", ['checked_in_at' => now()->toIso8601String()])
            ->assertOk()
            ->assertJsonPath('data.checked_in_at', fn ($value) => $value !== null);

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.arrivals.checked_in_count', 1);
    }

    public function test_transport_arranged_count_reflects_guests_with_transport_assignments(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $group = $wedding->transportGroups()->create([
            'name' => 'Shuttle A',
            'type' => 'shuttle',
            'capacity' => 10,
        ]);
        $wedding->guests()->create([
            'first_name' => 'Ada', 'travel_required' => true, 'transport_assignment_id' => $group->id,
        ]);
        $wedding->guests()->create([
            'first_name' => 'Ben', 'travel_required' => true,
        ]);
        $wedding->guests()->create([
            'first_name' => 'Cara', 'travel_required' => false,
        ]);

        Sanctum::actingAs($owner);

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.transport.arranged', 1)
            ->assertJsonPath('data.transport.total_requiring', 2);
    }

    public function test_vendor_can_be_checked_in_and_appears_in_live_today_roster(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $vendor = $wedding->vendors()->create([
            'name' => 'Sunset Gardens',
            'category' => 'Venue',
            'booking_status' => 'confirmed',
        ]);
        $unconfirmed = $wedding->vendors()->create([
            'name' => 'Maybe Florist',
            'category' => 'Florist',
            'booking_status' => 'researching',
        ]);

        Sanctum::actingAs($owner);

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.vendors.confirmed', 1)
            ->assertJsonPath('data.vendors.checked_in_count', 0)
            ->assertJsonCount(1, 'data.vendors.roster')
            ->assertJsonPath('data.vendors.roster.0.id', $vendor->id);

        $this->patchJson("/api/plan/vendors/{$vendor->id}", ['checked_in_at' => now()->toIso8601String()])
            ->assertOk();

        $this->getJson('/api/live/today')
            ->assertOk()
            ->assertJsonPath('data.vendors.checked_in_count', 1);

        $this->assertNull($unconfirmed->fresh()->checked_in_at);
    }

    public function test_guest_checkin_requires_manage_guests_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Sarah']);
        $viewer = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        Sanctum::actingAs($viewer);
        $this->patchJson("/api/guests/{$guest->id}", ['checked_in_at' => now()->toIso8601String()])
            ->assertForbidden();
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
