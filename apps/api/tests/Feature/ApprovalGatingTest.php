<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ApprovalGatingTest extends TestCase
{
    use RefreshDatabase;

    public function test_budget_increase_with_a_real_other_decision_maker_is_gated_until_approved(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['budget']);
        $item = $wedding->budgetItems()->create(['name' => 'Catering', 'estimated_amount' => 2000]);

        Sanctum::actingAs($owner);
        $response = $this->patchJson("/api/plan/budget/{$item->id}", ['estimated_amount' => 2500])
            ->assertOk()
            ->assertJsonPath('gated', true);

        $this->assertSame(2000.0, (float) $item->fresh()->estimated_amount);

        $approvalId = $response->json('approval_request_id');
        $decisionMaker = $wedding->collaborators()->first();
        Sanctum::actingAs($decisionMaker->user);

        $this->postJson("/api/approvals/{$approvalId}/vote", ['decision' => 'approve'])
            ->assertOk()
            ->assertJsonPath('data.status', 'approved');

        $this->assertSame(2500.0, (float) $item->fresh()->estimated_amount);
    }

    public function test_rejecting_a_budget_increase_leaves_the_amount_unchanged(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['budget']);
        $item = $wedding->budgetItems()->create(['name' => 'Catering', 'estimated_amount' => 2000]);

        Sanctum::actingAs($owner);
        $response = $this->patchJson("/api/plan/budget/{$item->id}", ['estimated_amount' => 2500])
            ->assertJsonPath('gated', true);

        $approvalId = $response->json('approval_request_id');
        $decisionMaker = $wedding->collaborators()->first();
        Sanctum::actingAs($decisionMaker->user);

        $this->postJson("/api/approvals/{$approvalId}/vote", ['decision' => 'reject'])
            ->assertOk()
            ->assertJsonPath('data.status', 'rejected');

        $this->assertSame(2000.0, (float) $item->fresh()->estimated_amount);
    }

    public function test_budget_increase_with_no_other_decision_maker_applies_immediately(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $item = $wedding->budgetItems()->create(['name' => 'Catering', 'estimated_amount' => 2000]);

        Sanctum::actingAs($owner);
        $this->patchJson("/api/plan/budget/{$item->id}", ['estimated_amount' => 2500])
            ->assertOk()
            ->assertJsonPath('gated', false)
            ->assertJsonPath('data.estimated_amount', '2500.00');
    }

    public function test_budget_increase_below_auto_approve_threshold_applies_immediately_despite_decision_maker(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['budget']);
        $wedding->update(['settings' => ['approval_auto_threshold' => 100]]);
        $item = $wedding->budgetItems()->create(['name' => 'Catering', 'estimated_amount' => 2000]);

        Sanctum::actingAs($owner);
        $this->patchJson("/api/plan/budget/{$item->id}", ['estimated_amount' => 2050])
            ->assertOk()
            ->assertJsonPath('gated', false);

        $this->assertSame(2050.0, (float) $item->fresh()->estimated_amount);
    }

    public function test_vendor_confirmation_with_a_decision_maker_is_gated_until_approved(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['vendors']);
        $vendor = $wedding->vendors()->create(['name' => 'Sound House', 'category' => 'Music', 'booking_status' => 'negotiating']);

        Sanctum::actingAs($owner);
        $response = $this->patchJson("/api/plan/vendors/{$vendor->id}", ['booking_status' => 'confirmed'])
            ->assertOk()
            ->assertJsonPath('gated', true);

        $this->assertSame('negotiating', $vendor->fresh()->booking_status);

        $approvalId = $response->json('approval_request_id');
        $decisionMaker = $wedding->collaborators()->first();
        Sanctum::actingAs($decisionMaker->user);

        $this->postJson("/api/approvals/{$approvalId}/vote", ['decision' => 'approve'])->assertOk();

        $this->assertSame('confirmed', $vendor->fresh()->booking_status);
    }

    public function test_collaborator_not_assigned_to_the_category_cannot_vote(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['budget']);
        $unrelatedDecisionMaker = $this->addDecisionMaker($wedding, $owner, ['attire']);
        $item = $wedding->budgetItems()->create(['name' => 'Catering', 'estimated_amount' => 2000]);

        Sanctum::actingAs($owner);
        $response = $this->patchJson("/api/plan/budget/{$item->id}", ['estimated_amount' => 2500])
            ->assertJsonPath('gated', true);
        $approvalId = $response->json('approval_request_id');

        Sanctum::actingAs($unrelatedDecisionMaker->user);
        $this->postJson("/api/approvals/{$approvalId}/vote", ['decision' => 'approve'])
            ->assertForbidden();
    }

    public function test_vendor_bulk_confirm_gates_some_and_applies_others(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $this->addDecisionMaker($wedding, $owner, ['vendors']);
        $gated = $wedding->vendors()->create(['name' => 'Sound House', 'category' => 'Music', 'booking_status' => 'negotiating']);
        $alreadyConfirmed = $wedding->vendors()->create(['name' => 'Florist Co', 'category' => 'Flowers', 'booking_status' => 'confirmed']);

        Sanctum::actingAs($owner);
        $response = $this->postJson('/api/plan/vendors/bulk-update', [
            'ids' => [$gated->id, $alreadyConfirmed->id],
            'updates' => ['booking_status' => 'confirmed'],
            'confirm' => true,
        ])->assertOk();

        $this->assertSame(0, $response->json('updated'));
        $this->assertSame(1, $response->json('pending_approval'));
        $this->assertSame('negotiating', $gated->fresh()->booking_status);
        $this->assertSame('confirmed', $alreadyConfirmed->fresh()->booking_status);
    }

    private function addDecisionMaker(Wedding $wedding, User $owner, array $categories)
    {
        $user = User::factory()->create(['active_wedding_id' => $wedding->id]);
        return $wedding->collaborators()->create([
            'user_id' => $user->id,
            'role' => 'planner',
            'is_decision_maker' => true,
            'approval_categories' => $categories,
            'invited_by' => $owner->id,
            'accepted_at' => now(),
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
