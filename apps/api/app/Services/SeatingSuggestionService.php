<?php

namespace App\Services;

use App\Models\Guest;
use App\Models\GuestPairing;
use App\Models\SeatingSeat;
use App\Models\SeatingTable;
use App\Models\Wedding;

/**
 * Deterministic, rule-based seat placement — never AI/generative. Every rule
 * here is a plain constraint or preference evaluated against real guest and
 * pairing data; "randomise" is a literal shuffle, not a fabricated feature.
 */
class SeatingSuggestionService
{
    public function generate(Wedding $wedding, array $rules): array
    {
        $keepCouples = $rules['keep_couples'] ?? true;
        $avoidDoNotSeat = $rules['avoid_do_not_seat'] ?? true;
        $seatElderlyTogether = $rules['seat_elderly_together'] ?? true;
        $balanceGroups = $rules['balance_groups'] ?? true;
        $randomise = $rules['randomise'] ?? false;

        $tables = $wedding->seatingTables()->with('seats')->get();
        $doNotSeatPairs = $avoidDoNotSeat
            ? $wedding->guestPairings()->where('type', 'do_not_seat')->get()
            : collect();

        $unassigned = $wedding->guests()
            ->where('attending_status', 'yes')
            ->whereNull('seating_assignment_id')
            ->get()
            ->keyBy('id');

        // Build placement units: couple-pairs first (as 2-guest units), then
        // remaining singles. Elderly singles are ordered first so they tend
        // to land at the same tables as each other.
        $units = [];
        $placedGuestIds = [];

        if ($keepCouples) {
            $couplePairs = $wedding->guestPairings()->where('type', 'couple')->get();
            foreach ($couplePairs as $pair) {
                if (isset($placedGuestIds[$pair->guest_id]) || isset($placedGuestIds[$pair->related_guest_id])) {
                    continue;
                }
                $a = $unassigned->get($pair->guest_id);
                $b = $unassigned->get($pair->related_guest_id);
                if ($a && $b) {
                    $units[] = ['guests' => [$a, $b]];
                    $placedGuestIds[$a->id] = true;
                    $placedGuestIds[$b->id] = true;
                }
            }
        }

        $remaining = $unassigned->reject(fn (Guest $g) => isset($placedGuestIds[$g->id]))->values();
        if ($seatElderlyTogether) {
            $remaining = $remaining->sortByDesc(fn (Guest $g) => $g->is_elderly ? 1 : 0)->values();
        }
        if ($randomise) {
            $remaining = $remaining->shuffle();
        }
        foreach ($remaining as $guest) {
            $units[] = ['guests' => [$guest]];
        }

        $seatedCount = 0;
        foreach ($units as $unit) {
            $size = count($unit['guests']);
            $isElderlyUnit = $seatElderlyTogether && $size === 1 && $unit['guests'][0]->is_elderly;
            $table = $this->pickTable($tables, $unit['guests'], $size, $doNotSeatPairs, $balanceGroups, $isElderlyUnit);
            if (! $table) {
                continue;
            }
            $openSeats = $table->seats->whereNull('guest_id')->values();
            foreach ($unit['guests'] as $i => $guest) {
                $seat = $openSeats[$i];
                $seat->update(['guest_id' => $guest->id]);
                Guest::where('id', $guest->id)->update(['seating_assignment_id' => $seat->id]);
                $seatedCount++;
            }
            // Reflect the just-filled seats so subsequent units see accurate capacity.
            $table->refresh()->load('seats');
        }

        foreach ($tables as $table) {
            $table->update(['assigned_count' => $table->seats()->whereNotNull('guest_id')->count()]);
        }

        return [
            'seated_count' => $seatedCount,
            'total_unassigned' => $unassigned->count(),
        ];
    }

    private function pickTable($tables, array $guests, int $size, $doNotSeatPairs, bool $balanceGroups, bool $preferElderlyCluster = false): ?SeatingTable
    {
        $guestIds = array_map(fn (Guest $g) => $g->id, $guests);

        $candidates = $tables->filter(function (SeatingTable $table) use ($size, $guestIds, $doNotSeatPairs) {
            $openSeats = $table->seats->whereNull('guest_id')->count();
            if ($openSeats < $size) {
                return false;
            }
            $seatedGuestIds = $table->seats->whereNotNull('guest_id')->pluck('guest_id')->all();
            foreach ($doNotSeatPairs as $pair) {
                $conflictsWithGuest = in_array($pair->guest_id, $guestIds) && in_array($pair->related_guest_id, $seatedGuestIds);
                $conflictsWithRelated = in_array($pair->related_guest_id, $guestIds) && in_array($pair->guest_id, $seatedGuestIds);
                if ($conflictsWithGuest || $conflictsWithRelated) {
                    return false;
                }
            }
            return true;
        });

        if ($candidates->isEmpty()) {
            return null;
        }

        if ($preferElderlyCluster) {
            $withElderly = $candidates->filter(function (SeatingTable $table) {
                $seatedGuestIds = $table->seats->whereNotNull('guest_id')->pluck('guest_id')->all();
                return Guest::whereIn('id', $seatedGuestIds)->where('is_elderly', true)->exists();
            });
            if ($withElderly->isNotEmpty()) {
                return $withElderly->first();
            }
        }

        if ($balanceGroups) {
            return $candidates->sortByDesc(fn (SeatingTable $t) => $t->seats->whereNull('guest_id')->count())->first();
        }

        return $candidates->first();
    }
}
