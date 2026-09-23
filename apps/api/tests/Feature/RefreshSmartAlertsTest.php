<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RefreshSmartAlertsTest extends TestCase
{
    use RefreshDatabase;

    public function test_hourly_refresh_generates_and_resolves_alerts_without_anyone_opening_the_app(): void
    {
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => User::factory()->create()->id,
            'rsvp_deadline' => now()->addDays(5)->toDateString(),
        ]);
        $guest = $wedding->guests()->create([
            'first_name' => 'Sarah',
            'last_name' => 'Brown',
            'attending_status' => 'pending',
        ]);

        $this->artisan('smart-alerts:refresh')->assertSuccessful();

        $this->assertDatabaseHas('smart_alerts', [
            'wedding_id' => $wedding->id,
            'key' => 'rsvp-deadline',
            'status' => 'active',
        ]);

        // Once the guest answers, the next run resolves the alert by itself.
        $guest->update(['attending_status' => 'no']);

        $this->artisan('smart-alerts:refresh')->assertSuccessful();

        $this->assertDatabaseHas('smart_alerts', [
            'wedding_id' => $wedding->id,
            'key' => 'rsvp-deadline',
            'status' => 'resolved',
        ]);
    }
}
