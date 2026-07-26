<?php

namespace App\Http\Controllers;

use App\Models\MoodCheckin;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Real, persisted mood check-ins for the Home screen's "How are you feeling
 * today?" card — insights() aggregates real history rather than the card
 * ever inventing a trend.
 */
class MoodController extends Controller
{
    private const MOODS = ['calm', 'excited', 'overwhelmed', 'balanced', 'grateful'];

    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 404, 'No active wedding.');
        return $wedding;
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'mood' => ['required', 'string', Rule::in(self::MOODS)],
        ]);

        $checkin = MoodCheckin::create([
            'wedding_id' => $wedding->id,
            'user_id' => $request->user()->id,
            'mood' => $data['mood'],
        ]);

        return response()->json(['data' => $checkin], 201);
    }

    public function insights(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $checkins = $wedding->moodCheckins()
            ->where('created_at', '>=', now()->subDays(30))
            ->get();

        $counts = collect(self::MOODS)->mapWithKeys(fn (string $mood) => [
            $mood => $checkins->where('mood', $mood)->count(),
        ]);

        $mostCommon = $counts->filter(fn (int $count) => $count > 0)->sortDesc()->keys()->first();

        return response()->json(['data' => [
            'total' => $checkins->count(),
            'counts' => $counts,
            'most_common' => $mostCommon,
        ]]);
    }
}
