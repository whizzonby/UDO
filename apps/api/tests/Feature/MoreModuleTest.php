<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MoreModuleTest extends TestCase
{
    use RefreshDatabase;

    public function test_named_wedding_party_role_presets_are_available(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $response = $this->getJson('/api/wedding/team')->assertOk();
        $roles = collect($response->json('roles'))->pluck('role');

        foreach (['bridal_assistant', 'maid_of_honour', 'best_man', 'parent'] as $role) {
            $this->assertTrue($roles->contains($role), "Expected role preset '{$role}' to be available.");
        }
        $this->assertSame(['budget', 'vendors', 'honeymoon', 'invitations', 'attire', 'seating', 'logistics', 'timeline'], $response->json('approval_categories'));
    }

    public function test_collaborator_can_be_invited_as_a_decision_maker(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $planner = User::factory()->create(['email' => 'planner@example.test']);
        Sanctum::actingAs($owner);

        $this->postJson('/api/wedding/team', [
            'email' => 'planner@example.test',
            'role' => 'planner',
            'is_decision_maker' => true,
            'approval_categories' => ['budget', 'vendors'],
        ])
            ->assertCreated()
            ->assertJsonPath('data.is_decision_maker', true)
            ->assertJsonPath('data.approval_categories.0', 'budget')
            ->assertJsonPath('data.approval_categories.1', 'vendors');

        $this->assertDatabaseHas('wedding_collaborators', [
            'wedding_id' => $wedding->id,
            'user_id' => $planner->id,
            'is_decision_maker' => true,
        ]);
    }

    public function test_existing_collaborator_can_be_toggled_as_decision_maker_without_resupplying_role(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['email' => 'viewer@example.test']);
        $collaborator = $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);
        Sanctum::actingAs($owner);

        $this->patchJson("/api/wedding/team/{$collaborator->id}", [
            'is_decision_maker' => true,
            'approval_categories' => ['seating'],
        ])
            ->assertOk()
            ->assertJsonPath('data.role', 'viewer')
            ->assertJsonPath('data.is_decision_maker', true)
            ->assertJsonPath('data.approval_categories.0', 'seating');

        // A follow-up update that doesn't touch decision-maker fields leaves them unaffected.
        $this->patchJson("/api/wedding/team/{$collaborator->id}", ['role' => 'finance'])
            ->assertOk()
            ->assertJsonPath('data.role', 'finance')
            ->assertJsonPath('data.is_decision_maker', true)
            ->assertJsonPath('data.approval_categories.0', 'seating');
    }

    public function test_wedding_settings_can_update_timezone(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->patchJson('/api/wedding', ['timezone' => 'America/New_York'])
            ->assertOk()
            ->assertJsonPath('timezone', 'America/New_York');

        $this->assertDatabaseHas('weddings', [
            'id' => $wedding->id,
            'timezone' => 'America/New_York',
        ]);
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
