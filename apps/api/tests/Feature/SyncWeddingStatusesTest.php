<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class SyncWeddingStatusesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Carbon::setTestNow(Carbon::parse('2026-09-23 14:00:00', 'UTC'));
    }

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    public function test_statuses_follow_the_wedding_date(): void
    {
        $farOff = $this->wedding('2027-03-22');
        $nextWeek = $this->wedding('2026-09-29');
        $today = $this->wedding('2026-09-23');
        $yesterday = $this->wedding('2026-09-22', 'live');

        $this->artisan('weddings:sync-statuses')->assertSuccessful();

        $this->assertSame('planning', $farOff->fresh()->status);
        $this->assertSame('final_week', $nextWeek->fresh()->status);
        $this->assertSame('live', $today->fresh()->status);
        $this->assertSame('completed', $yesterday->fresh()->status);
    }

    public function test_uses_the_weddings_own_timezone(): void
    {
        // 14:00 UTC on the 23rd is already 02:00 on the 24th in Auckland.
        $auckland = $this->wedding('2026-09-24', 'planning', 'Pacific/Auckland');
        $london = $this->wedding('2026-09-24', 'planning', 'Europe/London');

        $this->artisan('weddings:sync-statuses')->assertSuccessful();

        $this->assertSame('live', $auckland->fresh()->status);
        $this->assertSame('final_week', $london->fresh()->status);
    }

    public function test_never_moves_a_wedding_backwards_or_touches_finished_ones(): void
    {
        $markedLiveEarly = $this->wedding('2026-09-26', 'live');
        $postWedding = $this->wedding('2026-09-20', 'post_wedding');

        $this->artisan('weddings:sync-statuses')->assertSuccessful();

        $this->assertSame('live', $markedLiveEarly->fresh()->status);
        $this->assertSame('post_wedding', $postWedding->fresh()->status);
    }

    public function test_dry_run_saves_nothing(): void
    {
        $nextWeek = $this->wedding('2026-09-29');

        $this->artisan('weddings:sync-statuses', ['--dry-run' => true])->assertSuccessful();

        $this->assertSame('planning', $nextWeek->fresh()->status);
    }

    private function wedding(string $date, string $status = 'planning', string $tz = 'UTC'): Wedding
    {
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => User::factory()->create()->id,
            'event_date' => $date,
            'timezone' => $tz,
        ]);
        $wedding->forceFill(['status' => $status])->save();

        return $wedding->fresh();
    }
}
