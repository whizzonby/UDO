<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WeddingPartyExtrasTest extends TestCase
{
    use RefreshDatabase;

    public function test_linking_an_existing_guest_tags_them_as_wedding_party_without_duplicating(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $guest = $wedding->guests()->create(['first_name' => 'Sarah', 'last_name' => 'Brown']);

        Sanctum::actingAs($owner);
        $this->patchJson("/api/guests/{$guest->id}", [
            'guest_group' => 'wedding_party',
            'wedding_party_role' => 'Bridesmaid',
        ])
            ->assertOk()
            ->assertJsonPath('data.guest_group', 'wedding_party')
            ->assertJsonPath('data.wedding_party_role', 'Bridesmaid');

        $this->assertSame(1, $wedding->guests()->count());
        $this->assertSame(1, $wedding->guests()->where('guest_group', 'wedding_party')->count());
    }

    public function test_responsibility_bulk_update_marks_multiple_as_done(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $one = $wedding->weddingPartyResponsibilities()->create(['title' => 'Call florist', 'status' => 'pending']);
        $two = $wedding->weddingPartyResponsibilities()->create(['title' => 'Confirm suits', 'status' => 'pending']);
        $other = Wedding::create(['couple_name_primary' => 'Other', 'owner_user_id' => User::factory()->create()->id]);
        $foreign = $other->weddingPartyResponsibilities()->create(['title' => 'Not mine', 'status' => 'pending']);

        Sanctum::actingAs($owner);

        $this->postJson('/api/wedding-party/responsibilities/bulk-update', [
            'ids' => [$one->id, $two->id],
            'updates' => ['status' => 'done'],
            'confirm' => true,
        ])
            ->assertOk()
            ->assertJsonPath('updated', 2);

        $this->assertSame('done', $one->fresh()->status);
        $this->assertSame('done', $two->fresh()->status);
        $this->assertSame('pending', $foreign->fresh()->status);
    }

    public function test_responsibility_bulk_update_rejects_ids_from_another_wedding(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $mine = $wedding->weddingPartyResponsibilities()->create(['title' => 'Mine', 'status' => 'pending']);
        $other = Wedding::create(['couple_name_primary' => 'Other', 'owner_user_id' => User::factory()->create()->id]);
        $foreign = $other->weddingPartyResponsibilities()->create(['title' => 'Not mine', 'status' => 'pending']);

        Sanctum::actingAs($owner);

        $this->postJson('/api/wedding-party/responsibilities/bulk-update', [
            'ids' => [$mine->id, $foreign->id],
            'updates' => ['status' => 'done'],
            'confirm' => true,
        ])->assertStatus(422);

        $this->assertSame('pending', $mine->fresh()->status);
    }

    public function test_responsibility_priority_is_set_and_validated(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $response = $this->postJson('/api/wedding-party/responsibilities', [
            'title' => 'Confirm transport',
            'priority' => 'high',
        ])->assertCreated();
        $id = $response->json('data.id');
        $this->assertSame('high', $wedding->weddingPartyResponsibilities()->find($id)->priority);

        $this->postJson('/api/wedding-party/responsibilities', [
            'title' => 'Bad priority',
            'priority' => 'urgent',
        ])->assertStatus(422);
    }

    public function test_responsibility_bulk_update_can_set_priority_and_is_wedding_scoped(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $one = $wedding->weddingPartyResponsibilities()->create(['title' => 'Call florist', 'status' => 'pending']);
        $other = Wedding::create(['couple_name_primary' => 'Other', 'owner_user_id' => User::factory()->create()->id]);
        $foreign = $other->weddingPartyResponsibilities()->create(['title' => 'Not mine', 'status' => 'pending']);

        Sanctum::actingAs($owner);
        $this->postJson('/api/wedding-party/responsibilities/bulk-update', [
            'ids' => [$one->id],
            'updates' => ['priority' => 'high'],
            'confirm' => true,
        ])->assertOk();

        $this->assertSame('high', $one->fresh()->priority);
        $this->assertSame('medium', $foreign->fresh()->priority);
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
