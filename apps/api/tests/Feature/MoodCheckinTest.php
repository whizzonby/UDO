<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MoodCheckinTest extends TestCase
{
    use RefreshDatabase;

    public function test_a_mood_checkin_is_persisted_for_the_active_wedding(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/mood-checkins', ['mood' => 'grateful'])->assertCreated();

        $this->assertDatabaseHas('mood_checkins', [
            'wedding_id' => $wedding->id,
            'user_id' => $owner->id,
            'mood' => 'grateful',
        ]);
    }

    public function test_an_invalid_mood_is_rejected(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/mood-checkins', ['mood' => 'furious'])->assertStatus(422);
    }

    public function test_insights_reflects_real_recorded_counts(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        foreach (['calm', 'calm', 'grateful'] as $mood) {
            $this->postJson('/api/mood-checkins', ['mood' => $mood])->assertCreated();
        }

        $this->getJson('/api/mood-checkins/insights')
            ->assertOk()
            ->assertJsonPath('data.total', 3)
            ->assertJsonPath('data.counts.calm', 2)
            ->assertJsonPath('data.counts.grateful', 1)
            ->assertJsonPath('data.counts.excited', 0)
            ->assertJsonPath('data.most_common', 'calm');
    }

    public function test_insights_only_counts_the_last_30_days(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $wedding->moodCheckins()->create([
            'user_id' => $owner->id,
            'mood' => 'excited',
            'created_at' => now()->subDays(45),
        ]);
        $this->postJson('/api/mood-checkins', ['mood' => 'balanced'])->assertCreated();

        $this->getJson('/api/mood-checkins/insights')
            ->assertOk()
            ->assertJsonPath('data.total', 1)
            ->assertJsonPath('data.most_common', 'balanced');
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
