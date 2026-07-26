<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SeatingRulesTest extends TestCase
{
    use RefreshDatabase;

    public function test_pairing_crud_is_wedding_scoped(): void
    {
        [$owner, $wedding] = $this->weddingWithGuests(2);
        $guests = $wedding->guests()->orderBy('id')->get();
        Sanctum::actingAs($owner);

        $response = $this->postJson('/api/seating/pairings', [
            'guest_id' => $guests[0]->id,
            'related_guest_id' => $guests[1]->id,
            'type' => 'couple',
        ])->assertCreated();
        $pairingId = $response->json('data.id');

        $this->getJson('/api/seating/pairings')->assertOk()->assertJsonCount(1, 'data');

        [$otherOwner] = $this->weddingWithGuests(0);
        Sanctum::actingAs($otherOwner);
        $this->deleteJson("/api/seating/pairings/{$pairingId}")->assertForbidden();

        Sanctum::actingAs($owner);
        $this->deleteJson("/api/seating/pairings/{$pairingId}")->assertNoContent();
    }

    public function test_auto_assign_keeps_a_couple_at_the_same_table(): void
    {
        [$owner, $wedding] = $this->weddingWithGuests(2);
        $guests = $wedding->guests()->orderBy('id')->get();
        $wedding->guestPairings()->create([
            'guest_id' => $guests[0]->id,
            'related_guest_id' => $guests[1]->id,
            'type' => 'couple',
        ]);
        $table = $this->createTable($wedding, 'Table 1', 4);

        Sanctum::actingAs($owner);
        $this->postJson('/api/seating/auto-assign', ['keep_couples' => true])->assertOk();

        $a = $guests[0]->fresh();
        $b = $guests[1]->fresh();
        $this->assertNotNull($a->seating_assignment_id);
        $this->assertNotNull($b->seating_assignment_id);
        $seatA = $a->seating_assignment_id;
        $seatB = $b->seating_assignment_id;
        $this->assertSame(
            \App\Models\SeatingSeat::find($seatA)->seating_table_id,
            \App\Models\SeatingSeat::find($seatB)->seating_table_id,
        );
    }

    public function test_auto_assign_never_seats_a_do_not_seat_pair_at_the_same_table(): void
    {
        [$owner, $wedding] = $this->weddingWithGuests(2);
        $guests = $wedding->guests()->orderBy('id')->get();
        $wedding->guestPairings()->create([
            'guest_id' => $guests[0]->id,
            'related_guest_id' => $guests[1]->id,
            'type' => 'do_not_seat',
        ]);
        // Only one table exists, with just enough seats for both — the
        // service must leave at least one of them unseated rather than
        // violate the do-not-seat constraint.
        $this->createTable($wedding, 'Table 1', 2);

        Sanctum::actingAs($owner);
        $this->postJson('/api/seating/auto-assign', ['avoid_do_not_seat' => true])->assertOk();

        $a = $guests[0]->fresh();
        $b = $guests[1]->fresh();
        $bothSeated = $a->seating_assignment_id && $b->seating_assignment_id;
        $this->assertFalse($bothSeated, 'Do-not-seat pair should never both be seated at the only table.');
    }

    public function test_summary_reflects_dietary_and_accessibility_counts(): void
    {
        [$owner, $wedding] = $this->weddingWithGuests(0);
        $wedding->guests()->create(['first_name' => 'Ann', 'attending_status' => 'yes', 'allergies' => 'Peanuts']);
        $wedding->guests()->create(['first_name' => 'Bo', 'attending_status' => 'yes', 'accessibility_needs' => true]);
        $wedding->guests()->create(['first_name' => 'Cid', 'attending_status' => 'yes']);

        Sanctum::actingAs($owner);
        $this->getJson('/api/seating/summary')
            ->assertOk()
            ->assertJsonPath('data.dietary_needs_count', 1)
            ->assertJsonPath('data.accessibility_count', 1);
    }

    private function createTable(Wedding $wedding, string $name, int $capacity)
    {
        $table = $wedding->seatingTables()->create(['name' => $name, 'shape' => 'round', 'capacity' => $capacity]);
        for ($i = 1; $i <= $capacity; $i++) {
            $table->seats()->create(['wedding_id' => $wedding->id, 'seat_number' => $i]);
        }
        return $table;
    }

    private function weddingWithGuests(int $guestCount): array
    {
        $user = User::factory()->create();
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => $user->id,
        ]);
        $user->update(['active_wedding_id' => $wedding->id]);

        for ($i = 0; $i < $guestCount; $i++) {
            $wedding->guests()->create(['first_name' => "Guest{$i}", 'attending_status' => 'yes']);
        }

        return [$user->fresh(), $wedding];
    }
}
