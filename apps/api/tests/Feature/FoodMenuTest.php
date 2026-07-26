<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FoodMenuTest extends TestCase
{
    use RefreshDatabase;

    public function test_course_and_option_crud_is_wedding_scoped(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $course = $this->postJson('/api/plan/food/courses', ['name' => 'Main Course', 'type' => 'main'])
            ->assertCreated()
            ->json('data');

        $option = $this->postJson("/api/plan/food/courses/{$course['id']}/options", ['name' => 'Grilled Chicken'])
            ->assertCreated()
            ->assertJsonPath('data.confirmed', false)
            ->json('data');

        $this->patchJson("/api/plan/food/options/{$option['id']}", ['confirmed' => true])
            ->assertOk()
            ->assertJsonPath('data.confirmed', true);

        [, $otherWedding] = $this->userWithWedding();
        $otherOwner = User::factory()->create();
        $otherWedding->update(['owner_user_id' => $otherOwner->id]);
        $otherOwner->update(['active_wedding_id' => $otherWedding->id]);
        Sanctum::actingAs($otherOwner);
        $this->patchJson("/api/plan/food/courses/{$course['id']}", ['name' => 'Hijacked'])->assertStatus(403);
        $this->deleteJson("/api/plan/food/options/{$option['id']}")->assertStatus(403);
    }

    public function test_selecting_a_main_course_option_syncs_guest_meal_preference(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $guest = $wedding->guests()->create(['first_name' => 'Ava', 'last_name' => 'Lee']);

        $course = $wedding->menuCourses()->create(['name' => 'Main Course', 'type' => 'main']);
        $option = $course->options()->create(['wedding_id' => $wedding->id, 'name' => 'Vegetarian Pasta']);

        $this->postJson("/api/plan/food/options/{$option->id}/select", ['guest_id' => $guest->id])->assertCreated();

        $this->assertDatabaseHas('guests', ['id' => $guest->id, 'meal_preference' => 'Vegetarian Pasta']);
        $this->assertDatabaseHas('guest_menu_selections', [
            'guest_id' => $guest->id,
            'menu_course_id' => $course->id,
            'menu_course_option_id' => $option->id,
        ]);

        // Selecting a different main-course option replaces the previous selection (unique per guest+course).
        $otherOption = $course->options()->create(['wedding_id' => $wedding->id, 'name' => 'Grilled Salmon']);
        $this->postJson("/api/plan/food/options/{$otherOption->id}/select", ['guest_id' => $guest->id])->assertCreated();
        $this->assertDatabaseHas('guests', ['id' => $guest->id, 'meal_preference' => 'Grilled Salmon']);
        $this->assertEquals(1, \App\Models\GuestMenuSelection::where('guest_id', $guest->id)->count());
    }

    public function test_summary_counts_are_real(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $g1 = $wedding->guests()->create(['first_name' => 'Ava', 'dietary_note' => 'No nuts']);
        $g2 = $wedding->guests()->create(['first_name' => 'Ben', 'allergies' => 'Shellfish']);
        $wedding->guests()->create(['first_name' => 'Cara']);

        $course = $wedding->menuCourses()->create(['name' => 'Main Course', 'type' => 'main']);
        $option = $course->options()->create(['wedding_id' => $wedding->id, 'name' => 'Chicken', 'confirmed' => true]);
        $unconfirmed = $course->options()->create(['wedding_id' => $wedding->id, 'name' => 'Beef']);
        $this->postJson("/api/plan/food/options/{$option->id}/select", ['guest_id' => $g1->id])->assertCreated();

        $response = $this->getJson('/api/plan/food')
            ->assertOk()
            ->assertJsonPath('data.summary.total_guests', 3)
            ->assertJsonPath('data.summary.meal_selections', 1)
            ->assertJsonPath('data.summary.dietary_needs', 2)
            ->assertJsonPath('data.summary.allergy_count', 1)
            ->assertJsonPath('data.summary.items_to_review', 1);

        $options = collect($response->json('data.courses.0.options'));
        $this->assertSame(1, $options->firstWhere('id', $option->id)['selections_count']);
        $this->assertSame(0, $options->firstWhere('id', $unconfirmed->id)['selections_count']);
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
