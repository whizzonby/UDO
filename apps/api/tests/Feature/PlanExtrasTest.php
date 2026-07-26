<?php

namespace Tests\Feature;

use App\Models\BudgetItem;
use App\Models\BudgetPaymentSchedule;
use App\Models\HoneymoonItem;
use App\Models\InsurancePolicy;
use App\Models\Reminder;
use App\Models\User;
use App\Models\Wedding;
use App\Models\WeddingWeekendEvent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PlanExtrasTest extends TestCase
{
    use RefreshDatabase;

    public function test_reminder_can_be_created_listed_and_completed(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/plan/reminders', [
            'title' => 'Confirm final headcount',
            'due_date' => now()->addDays(3)->toDateString(),
            'priority' => 'high',
        ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Confirm final headcount')
            ->assertJsonPath('data.source', 'manual');

        $reminder = Reminder::first();

        $this->getJson('/api/plan/reminders')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $this->patchJson("/api/plan/reminders/{$reminder->id}", ['status' => 'completed'])
            ->assertOk()
            ->assertJsonPath('data.status', 'completed');
    }

    public function test_reminder_refresh_generates_auto_reminder_from_unpaid_budget_schedule_and_removes_it_once_paid(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $budgetItem = $wedding->budgetItems()->create([
            'name' => 'Florist',
            'category' => 'Flowers',
            'estimated_amount' => 2000,
        ]);
        $schedule = BudgetPaymentSchedule::create([
            'wedding_id' => $wedding->id,
            'budget_item_id' => $budgetItem->id,
            'label' => 'Final payment',
            'amount' => 500,
            'due_date' => now()->addDays(5)->toDateString(),
            'status' => 'pending',
        ]);

        Sanctum::actingAs($owner);

        $this->postJson('/api/plan/reminders/refresh')->assertOk();

        $reminder = Reminder::where('source', 'auto')->first();
        $this->assertNotNull($reminder);
        $this->assertSame("budget_payment_schedule:{$schedule->id}", $reminder->source_key);

        $schedule->update(['status' => 'paid']);
        $this->postJson('/api/plan/reminders/refresh')->assertOk();

        $this->assertSame(0, Reminder::where('source', 'auto')->count());
    }

    public function test_insurance_policy_crud(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/plan/insurance', [
            'provider' => 'SafeWed Insurance',
            'coverage_amount' => 50000,
            'end_date' => now()->addMonths(6)->toDateString(),
        ])
            ->assertCreated()
            ->assertJsonPath('data.provider', 'SafeWed Insurance');

        $policy = InsurancePolicy::first();

        $this->getJson('/api/plan/insurance')->assertOk()->assertJsonCount(1, 'data');

        $this->patchJson("/api/plan/insurance/{$policy->id}", ['status' => 'cancelled'])
            ->assertOk()
            ->assertJsonPath('data.status', 'cancelled');

        $this->deleteJson("/api/plan/insurance/{$policy->id}")->assertNoContent();
        $this->assertSame(0, InsurancePolicy::count());
    }

    public function test_wedding_weekend_event_crud(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/plan/wedding-weekend', [
            'title' => 'Rehearsal dinner',
            'event_date' => now()->addDays(30)->toDateString(),
            'audience' => 'wedding_party',
        ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Rehearsal dinner');

        $event = WeddingWeekendEvent::first();

        $this->getJson('/api/plan/wedding-weekend')->assertOk()->assertJsonCount(1, 'data');

        $this->patchJson("/api/plan/wedding-weekend/{$event->id}", ['location' => 'The Grand Hall'])
            ->assertOk()
            ->assertJsonPath('data.location', 'The Grand Hall');

        $this->deleteJson("/api/plan/wedding-weekend/{$event->id}")->assertNoContent();
    }

    public function test_honeymoon_trip_is_a_singleton_created_on_first_update(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->getJson('/api/plan/honeymoon')
            ->assertOk()
            ->assertJsonPath('data', null);

        $this->patchJson('/api/plan/honeymoon', [
            'destination' => 'Bali',
            'checklist' => ['passport_validity' => true, 'visa_requirements' => false],
        ])
            ->assertOk()
            ->assertJsonPath('data.destination', 'Bali');

        $this->assertSame(1, $wedding->honeymoonTrip()->count());

        // A second update must not create a second trip row.
        $this->patchJson('/api/plan/honeymoon', ['destination' => 'Maldives'])
            ->assertOk()
            ->assertJsonPath('data.destination', 'Maldives');
        $this->assertSame(1, $wedding->honeymoonTrip()->count());
    }

    public function test_honeymoon_items_are_scoped_to_the_wedding_trip(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        [$otherOwner, $otherWedding] = $this->userWithWedding();

        Sanctum::actingAs($owner);
        $this->patchJson('/api/plan/honeymoon', ['destination' => 'Bali'])->assertOk();

        $this->postJson('/api/plan/honeymoon/items', [
            'type' => 'flight',
            'title' => 'Outbound flight',
            'details' => ['airline' => 'Delta', 'flight_number' => 'DL123'],
        ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Outbound flight');

        $item = HoneymoonItem::first();

        // A collaborator on a different wedding must not be able to touch this item.
        Sanctum::actingAs($otherOwner);
        $this->patchJson("/api/plan/honeymoon/items/{$item->id}", ['title' => 'Hijacked'])
            ->assertForbidden();

        Sanctum::actingAs($owner);
        $this->deleteJson("/api/plan/honeymoon/items/{$item->id}")->assertNoContent();
    }

    public function test_plan_extras_require_manage_plan_permission(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $viewer = User::factory()->create(['active_wedding_id' => $wedding->id]);
        $wedding->collaborators()->create([
            'user_id' => $viewer->id,
            'role' => 'viewer',
            'permissions' => ['view_reports'],
            'invited_by' => $owner->id,
            'accepted_at' => now(),
        ]);

        Sanctum::actingAs($viewer);
        $this->postJson('/api/plan/reminders', ['title' => 'Blocked'])->assertForbidden();
        $this->postJson('/api/plan/insurance', ['provider' => 'Blocked'])->assertForbidden();
        $this->postJson('/api/plan/wedding-weekend', ['title' => 'Blocked', 'event_date' => now()->toDateString()])->assertForbidden();
        $this->patchJson('/api/plan/honeymoon', ['destination' => 'Blocked'])->assertForbidden();
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
