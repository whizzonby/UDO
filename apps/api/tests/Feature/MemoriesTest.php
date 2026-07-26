<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemoriesTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_manage_speeches_and_private_ones_are_hidden_from_non_core_collaborators(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = $this->addCollaborator($wedding, $owner, 'viewer', ['manage_plan']);
        Sanctum::actingAs($owner);

        $shared = $this->postJson('/api/plan/memories/speeches', [
            'speaker_name' => 'Best Man',
            'confirmed' => true,
            'visibility' => 'shared',
        ])->assertCreated()->json('data');

        $private = $this->postJson('/api/plan/memories/speeches', [
            'speaker_name' => 'Maid of Honour',
            'visibility' => 'private',
        ])->assertCreated()->json('data');

        $this->getJson('/api/plan/memories/speeches')->assertOk()->assertJsonCount(2, 'data');

        Sanctum::actingAs($viewer);
        $this->getJson('/api/plan/memories/speeches')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $shared['id']);

        $this->patchJson("/api/plan/memories/speeches/{$private['id']}", ['confirmed' => true])->assertOk();
    }

    public function test_vows_are_private_by_default_and_hidden_from_non_core_collaborators(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $partner = $this->addCollaborator($wedding, $owner, 'partner', []);
        $planner = $this->addCollaborator($wedding, $owner, 'planner', ['manage_plan']);
        Sanctum::actingAs($owner);

        $vow = $this->postJson('/api/plan/memories/vows', [
            'title' => "Amara's vows",
            'draft_text' => 'I promise...',
        ])->assertCreated()->assertJsonPath('data.is_private', true)->json('data');

        Sanctum::actingAs($partner);
        $this->getJson('/api/plan/memories/vows')->assertOk()->assertJsonCount(1, 'data');

        Sanctum::actingAs($planner);
        $this->getJson('/api/plan/memories/vows')->assertOk()->assertJsonCount(0, 'data');

        Sanctum::actingAs($owner);
        $this->patchJson("/api/plan/memories/vows/{$vow['id']}", ['is_private' => false])->assertOk();

        Sanctum::actingAs($planner);
        $this->getJson('/api/plan/memories/vows')->assertOk()->assertJsonCount(1, 'data');
    }

    public function test_traditions_crud_and_visibility_filtering(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $tradition = $this->postJson('/api/plan/memories/traditions', [
            'name' => 'Kente cloth presentation',
            'person_responsible' => 'Aunt Efua',
        ])->assertCreated()->json('data');

        $this->getJson('/api/plan/memories/traditions')->assertOk()->assertJsonCount(1, 'data');
        $this->deleteJson("/api/plan/memories/traditions/{$tradition['id']}")->assertNoContent();
        $this->getJson('/api/plan/memories/traditions')->assertOk()->assertJsonCount(0, 'data');
    }

    public function test_photo_booth_and_music_singletons_get_and_update(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->getJson('/api/plan/memories/photo-booth')->assertOk()->assertJsonPath('data', null);
        $this->patchJson('/api/plan/memories/photo-booth', ['vendor_name' => 'Snap Booth Co', 'status' => 'booked'])
            ->assertOk()
            ->assertJsonPath('data.vendor_name', 'Snap Booth Co');

        $this->getJson('/api/plan/memories/music')->assertOk()->assertJsonPath('data', null);
        $this->patchJson('/api/plan/memories/music', [
            'first_dance_song' => 'At Last',
            'other_moments' => [['label' => 'Garter toss', 'song' => 'Legs']],
        ])->assertOk()->assertJsonPath('data.first_dance_song', 'At Last');
    }

    public function test_guestbook_singleton_and_entry_moderation(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->patchJson('/api/plan/memories/guestbook', ['type' => 'digital', 'digital_enabled' => true])
            ->assertOk()
            ->assertJsonPath('data.type', 'digital');

        $guestbook = $wedding->memoryGuestbook()->firstOrFail();
        $entry = $guestbook->entries()->create(['guest_name' => 'Aunt Carol', 'message' => 'So happy for you both!']);

        $this->getJson('/api/plan/memories/guestbook')->assertOk()->assertJsonCount(1, 'data.entries');

        $this->patchJson("/api/plan/memories/guestbook/entries/{$entry->id}", ['approved' => true])
            ->assertOk()
            ->assertJsonPath('data.approved', true);

        $this->deleteJson("/api/plan/memories/guestbook/entries/{$entry->id}")->assertNoContent();
    }

    public function test_guest_can_submit_guestbook_message_only_when_allow_messages_is_open_and_it_needs_approval_to_appear_publicly(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Aunt', 'last_name' => 'Carol']);
        $token = $wedding->guestTokens()->create(['guest_id' => $guest->id, 'view_type' => 'invite']);

        // Not open yet — allow_messages defaults false.
        $config = $wedding->experienceConfig()->create(['publish_state' => 'published']);
        $this->postJson("/api/g/{$token->token}/guestbook", ['message' => 'Congrats!'])->assertForbidden();

        $config->update(['allow_messages' => true]);

        $this->postJson("/api/g/{$token->token}/guestbook", ['message' => 'Congratulations to you both!'])
            ->assertCreated()
            ->assertJsonPath('data.approved', false);

        // Not approved yet — shouldn't show in the public portal payload.
        $this->getJson("/api/g/{$token->token}")
            ->assertOk()
            ->assertJsonPath('sections.guestbook', []);

        $entry = $wedding->memoryGuestbook->entries()->firstOrFail();
        Sanctum::actingAs($owner);
        $this->patchJson("/api/plan/memories/guestbook/entries/{$entry->id}", ['approved' => true])->assertOk();

        $this->getJson("/api/g/{$token->token}")
            ->assertOk()
            ->assertJsonCount(1, 'sections.guestbook')
            ->assertJsonPath('sections.guestbook.0.guest_name', 'Aunt Carol');
    }

    private function addCollaborator(Wedding $wedding, User $owner, string $role, array $permissions): User
    {
        $user = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $user->id,
            'role' => $role,
            'permissions' => $permissions,
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        return $user->fresh();
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
