<?php

namespace Tests\Feature;

use App\Models\Message;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class InvitationWizardTest extends TestCase
{
    use RefreshDatabase;

    public function test_preview_filters_by_travel_required_has_phone_and_added_after(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $wedding->guests()->create([
            'first_name' => 'Traveling', 'last_name' => 'Guest',
            'email' => 'traveling@example.test', 'travel_required' => true,
        ]);
        $wedding->guests()->create([
            'first_name' => 'Local', 'last_name' => 'Guest',
            'email' => 'local@example.test', 'travel_required' => false,
        ]);
        $wedding->guests()->create([
            'first_name' => 'Phone', 'last_name' => 'Only',
            'phone' => '+15550001111', 'travel_required' => false,
        ]);

        $this->postJson('/api/invitation/campaigns/preview', [
            'audience_filter' => ['travel_required' => true],
        ])->assertOk()->assertJsonPath('data.recipient_count', 1);

        $this->postJson('/api/invitation/campaigns/preview', [
            'audience_filter' => ['has_phone' => true],
        ])->assertOk()->assertJsonPath('data.recipient_count', 1);

        $this->postJson('/api/invitation/campaigns/preview', [
            'audience_filter' => ['added_after' => now()->addDay()->toDateString()],
        ])->assertOk()->assertJsonPath('data.recipient_count', 0);
    }

    public function test_preview_returns_accurate_contact_breakdown(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $wedding->guests()->create(['first_name' => 'Has', 'last_name' => 'Both', 'email' => 'a@example.test', 'phone' => '+15550001111']);
        $wedding->guests()->create(['first_name' => 'Has', 'last_name' => 'Email', 'email' => 'b@example.test']);
        $wedding->guests()->create(['first_name' => 'Has', 'last_name' => 'Neither']);

        $response = $this->postJson('/api/invitation/campaigns/preview', [])
            ->assertOk();

        $this->assertSame(2, $response->json('data.contact_breakdown.with_email'));
        $this->assertSame(1, $response->json('data.contact_breakdown.with_phone'));
        $this->assertSame(1, $response->json('data.contact_breakdown.missing_contact'));
    }

    public function test_guest_links_endpoint_returns_real_portal_links_and_creates_tokens(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $guest = $wedding->guests()->create(['first_name' => 'Sarah', 'last_name' => 'Lee', 'email' => 'sarah@example.test']);

        $campaign = Message::create([
            'wedding_id' => $wedding->id,
            'campaign_name' => 'Save the date',
            'campaign_type' => 'invitation',
            'message_type' => 'invitation',
            'subject' => 'Hi {{first_name}}',
            'body' => 'See you there: {{rsvp_url}}',
            'channel' => 'email',
            'audience_filter' => [],
            'status' => 'draft',
            'created_by' => $owner->id,
        ]);

        $this->assertDatabaseCount('guest_tokens', 0);

        $response = $this->getJson("/api/invitation/campaigns/{$campaign->id}/guest-links")
            ->assertOk();

        $this->assertDatabaseCount('guest_tokens', 1);
        $this->assertSame('Sarah Lee', $response->json('data.0.name'));
        $this->assertNotNull($response->json('data.0.link'));
        $this->assertStringContainsString('/g/', $response->json('data.0.link'));

        // Calling again reuses the existing token instead of creating a second one.
        $this->getJson("/api/invitation/campaigns/{$campaign->id}/guest-links")->assertOk();
        $this->assertDatabaseCount('guest_tokens', 1);
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
