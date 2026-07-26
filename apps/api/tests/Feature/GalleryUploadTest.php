<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GalleryUploadTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_fetch_wedding_wide_upload_link(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $response = $this->getJson('/api/gallery/upload-link')
            ->assertOk();

        $token = $response->json('data.token');
        $this->assertNotEmpty($token);
        $frontendUrl = rtrim(config('app.frontend_url'), '/');
        $this->assertSame("{$frontendUrl}/upload/{$token}", $response->json('data.url'));
        $this->assertSame($token, $wedding->fresh()->gallery_upload_token);

        // Calling it again reuses the same token instead of regenerating it.
        $this->getJson('/api/gallery/upload-link')
            ->assertOk()
            ->assertJsonPath('data.token', $token);
    }

    public function test_public_upload_link_accepts_photo_when_uploads_are_open(): void
    {
        Storage::fake('public');
        [$owner, $wedding] = $this->userWithWedding();
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'allow_photo_uploads' => true,
        ]);
        $token = $wedding->ensureGalleryUploadToken();

        $this->getJson("/api/upload/{$token}")
            ->assertOk()
            ->assertJsonPath('data.uploads_open', true)
            ->assertJsonPath('data.couple_name_primary', $wedding->couple_name_primary);

        $this->post("/api/upload/{$token}/gallery", [
            'file' => UploadedFile::fake()->create('reception.jpg', 64, 'image/jpeg'),
            'uploaded_by_name' => 'Aunt Carol',
        ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.approved', false)
            ->assertJsonPath('data.album', 'guest_uploads')
            ->assertJsonPath('data.uploaded_by_name', 'Aunt Carol');

        Sanctum::actingAs($owner);
        $this->getJson('/api/gallery/summary')
            ->assertOk()
            ->assertJsonPath('data.pending_assets', 1)
            ->assertJsonPath('data.albums.guest_uploads_pending.0.uploaded_by_role', 'Aunt Carol');
    }

    public function test_public_upload_link_is_blocked_when_uploads_are_not_open(): void
    {
        [, $wedding] = $this->userWithWedding();
        $token = $wedding->ensureGalleryUploadToken();
        // Wedding has no experience config yet — allow_photo_uploads defaults to false.

        $this->getJson("/api/upload/{$token}")
            ->assertOk()
            ->assertJsonPath('data.uploads_open', false);

        $this->post("/api/upload/{$token}/gallery", [
            'file' => UploadedFile::fake()->create('reception.jpg', 64, 'image/jpeg'),
        ], ['Accept' => 'application/json'])
            ->assertForbidden();
    }

    public function test_unknown_upload_token_returns_not_found(): void
    {
        $this->getJson('/api/upload/does-not-exist')->assertNotFound();
    }

    public function test_guest_upload_shows_real_wedding_party_role_badge(): void
    {
        Storage::fake('public');
        [$owner, $wedding] = $this->userWithWedding();
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'allow_photo_uploads' => true,
        ]);
        $guest = $wedding->guests()->create([
            'first_name' => 'Priya',
            'last_name' => 'Nair',
            'wedding_party_role' => 'Bridesmaid',
        ]);
        $token = $wedding->guestTokens()->create(['guest_id' => $guest->id, 'view_type' => 'invite']);

        $this->post("/api/g/{$token->token}/gallery", [
            'file' => UploadedFile::fake()->create('dance.jpg', 64, 'image/jpeg'),
        ], ['Accept' => 'application/json'])->assertCreated();

        Sanctum::actingAs($owner);
        $this->getJson('/api/gallery/summary')
            ->assertOk()
            ->assertJsonPath('data.albums.guest_uploads_pending.0.uploaded_by_role', 'Bridesmaid');
    }

    public function test_inspiration_images_can_be_grouped_into_named_boards(): void
    {
        Storage::fake('public');
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $first = $this->postJson('/api/gallery', [
            'url' => 'https://example.test/florals-1.jpg',
            'album' => 'inspiration',
        ])->assertCreated()->json('data');
        $second = $this->postJson('/api/gallery', [
            'url' => 'https://example.test/florals-2.jpg',
            'album' => 'inspiration',
        ])->assertCreated()->json('data');

        $this->patchJson("/api/gallery/{$first['id']}", ['board_name' => 'Floral Inspiration'])
            ->assertOk()
            ->assertJsonPath('data.board_name', 'Floral Inspiration');
        $this->patchJson("/api/gallery/{$second['id']}", ['board_name' => 'Floral Inspiration'])
            ->assertOk();

        $boards = $this->getJson('/api/gallery/summary')->assertOk()->json('data.boards');
        $floral = collect($boards)->firstWhere('name', 'Floral Inspiration');
        $this->assertNotNull($floral);
        $this->assertSame(2, $floral['count']);
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
