<?php

namespace Tests\Feature;

use App\Jobs\SendGuestMessageDeliveryJob;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ThankYouMessageTest extends TestCase
{
    use RefreshDatabase;

    public function test_thank_you_message_dispatches_to_a_specific_guest_via_existing_infra(): void
    {
        Queue::fake();
        [$owner, $wedding] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $guest = $wedding->guests()->create(['first_name' => 'Aunt', 'last_name' => 'Carol', 'email' => 'carol@example.test']);
        $otherGuest = $wedding->guests()->create(['first_name' => 'Uncle', 'last_name' => 'Bob', 'email' => 'bob@example.test']);

        $created = $this->postJson('/api/messages', [
            'subject' => 'Thank you {{first_name}}!',
            'body' => 'Thank you so much for the gift, {{first_name}}. Love, {{couple_names}}',
            'channel' => 'email',
            'message_type' => 'thank_you',
            'audience_filter' => ['guest_ids' => [$guest->id]],
        ])->assertCreated()->json('data');

        $this->postJson("/api/messages/{$created['id']}/send")
            ->assertOk()
            ->assertJsonPath('recipients', 1);

        $this->assertDatabaseHas('guest_message_deliveries', [
            'message_id' => $created['id'],
            'guest_id' => $guest->id,
        ]);
        $this->assertDatabaseMissing('guest_message_deliveries', [
            'message_id' => $created['id'],
            'guest_id' => $otherGuest->id,
        ]);
        Queue::assertPushed(SendGuestMessageDeliveryJob::class, 1);
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
