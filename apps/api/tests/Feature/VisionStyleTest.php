<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class VisionStyleTest extends TestCase
{
    use RefreshDatabase;

    public function test_wedding_settings_can_save_and_retrieve_vision_style_data(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $payload = [
            'theme' => 'Tropical Garden',
            'mood_words' => ['romantic', 'lush', 'golden-hour'],
            'must_have_elements' => ['live band'],
            'elements_to_avoid' => ['confetti'],
            'color_palette' => [
                'name' => 'Sunset Grove',
                'colors' => [
                    ['hex' => '#F4A261', 'label' => 'Amber'],
                    ['hex' => '#2A9D8F', 'label' => 'Teal'],
                ],
                'primary_index' => 0,
                'accent_index' => 1,
            ],
        ];

        $this->patchJson('/api/wedding', ['vision_style' => $payload])
            ->assertOk()
            ->assertJsonPath('vision_style.theme', 'Tropical Garden')
            ->assertJsonPath('vision_style.color_palette.name', 'Sunset Grove');

        $this->assertSame($payload, $wedding->fresh()->vision_style);
    }

    public function test_gallery_asset_can_be_tagged_with_a_valid_inspiration_category(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $asset = $this->postJson('/api/gallery', [
            'url' => 'https://example.test/florals.jpg',
            'album' => 'inspiration',
            'category' => 'flowers',
        ])->assertCreated()->assertJsonPath('data.category', 'flowers')->json('data');

        $this->patchJson("/api/gallery/{$asset['id']}", ['category' => 'tables'])
            ->assertOk()
            ->assertJsonPath('data.category', 'tables');
    }

    public function test_gallery_asset_rejects_an_invalid_inspiration_category(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/gallery', [
            'url' => 'https://example.test/florals.jpg',
            'album' => 'inspiration',
            'category' => 'not-a-real-category',
        ])->assertStatus(422);
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
