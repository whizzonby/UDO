<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GalleryJourneyStageTest extends TestCase
{
    use RefreshDatabase;

    public function test_tagging_an_asset_with_a_journey_stage_groups_it_in_summary(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $engagementAsset = $wedding->galleryAssets()->create([
            'type' => 'photo', 'source' => 'upload', 'url' => 'https://example.test/a.jpg', 'album' => 'moments',
        ]);
        $honeymoonAsset = $wedding->galleryAssets()->create([
            'type' => 'photo', 'source' => 'upload', 'url' => 'https://example.test/b.jpg', 'album' => 'moments',
        ]);
        $untagged = $wedding->galleryAssets()->create([
            'type' => 'photo', 'source' => 'upload', 'url' => 'https://example.test/c.jpg', 'album' => 'moments',
        ]);

        $this->patchJson("/api/gallery/{$engagementAsset->id}", ['journey_stage' => 'engagement'])
            ->assertOk()
            ->assertJsonPath('data.journey_stage', 'engagement');
        $this->patchJson("/api/gallery/{$honeymoonAsset->id}", ['journey_stage' => 'honeymoon'])->assertOk();

        $response = $this->getJson('/api/gallery/summary')->assertOk();
        $journey = collect($response->json('data.journey'));

        $this->assertSame(1, $journey->firstWhere('stage', 'engagement')['count']);
        $this->assertSame(1, $journey->firstWhere('stage', 'honeymoon')['count']);
        $this->assertNull($untagged->fresh()->journey_stage);
    }

    public function test_invalid_journey_stage_is_rejected(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);
        $asset = $wedding->galleryAssets()->create(['type' => 'photo', 'source' => 'upload', 'url' => 'https://example.test/a.jpg', 'album' => 'moments']);

        $this->patchJson("/api/gallery/{$asset->id}", ['journey_stage' => 'not-a-real-stage'])->assertStatus(422);
    }

    public function test_journey_stage_update_is_wedding_scoped(): void
    {
        [, $wedding] = $this->userWithWedding();
        $asset = $wedding->galleryAssets()->create(['type' => 'photo', 'source' => 'upload', 'url' => 'https://example.test/a.jpg', 'album' => 'moments']);

        [$otherOwner] = $this->userWithWedding();
        Sanctum::actingAs($otherOwner);

        $this->patchJson("/api/gallery/{$asset->id}", ['journey_stage' => 'engagement'])->assertStatus(403);
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
