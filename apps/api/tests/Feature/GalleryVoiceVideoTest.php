<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GalleryVoiceVideoTest extends TestCase
{
    use RefreshDatabase;

    public function test_owners_own_video_upload_is_typed_video_not_photo(): void
    {
        Storage::fake('public');
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        // Mobile never sends a `type` field — this must be resolved from the
        // real uploaded file's mimetype, not defaulted to 'photo'.
        $this->postJson('/api/gallery', [
            'file' => UploadedFile::fake()->create('firstdance.mp4', 512, 'video/mp4'),
            'album' => 'moments',
        ])->assertCreated()->assertJsonPath('data.type', 'video');
    }

    public function test_owners_own_voice_upload_is_typed_voice(): void
    {
        Storage::fake('public');
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/gallery', [
            'file' => UploadedFile::fake()->create('note.mp3', 64, 'audio/mpeg'),
            'album' => 'moments',
        ])->assertCreated()->assertJsonPath('data.type', 'voice');
    }

    public function test_owners_own_photo_upload_still_typed_photo(): void
    {
        Storage::fake('public');
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/gallery', [
            'file' => UploadedFile::fake()->create('reception.jpg', 64, 'image/jpeg'),
            'album' => 'moments',
        ])->assertCreated()->assertJsonPath('data.type', 'photo');
    }

    public function test_guest_token_upload_accepts_voice_note(): void
    {
        Storage::fake('public');
        [, $wedding] = $this->userWithWedding();
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'allow_photo_uploads' => true,
        ]);
        $guest = $wedding->guests()->create(['first_name' => 'Priya', 'last_name' => 'Nair']);
        $token = $wedding->guestTokens()->create(['guest_id' => $guest->id, 'view_type' => 'invite']);

        $this->post("/api/g/{$token->token}/gallery", [
            'file' => UploadedFile::fake()->create('congrats.m4a', 64, 'audio/mp4'),
        ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.type', 'voice');
    }

    public function test_qr_upload_link_accepts_voice_note(): void
    {
        Storage::fake('public');
        [, $wedding] = $this->userWithWedding();
        $wedding->experienceConfig()->create([
            'publish_state' => 'published',
            'allow_photo_uploads' => true,
        ]);
        $token = $wedding->ensureGalleryUploadToken();

        $this->post("/api/upload/{$token}/gallery", [
            'file' => UploadedFile::fake()->create('voice-message.wav', 64, 'audio/wav'),
            'uploaded_by_name' => 'Aunt Carol',
        ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.type', 'voice');
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
