<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WeddingController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding, 404, 'No wedding found.');

        return response()->json($wedding);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding, 404, 'No wedding found.');

        $data = $request->validate([
            'title'                 => 'nullable|string|max:255',
            'couple_name_primary'   => 'nullable|string|max:255',
            'couple_name_secondary' => 'nullable|string|max:255',
            'event_date'            => 'nullable|date',
            'city'                  => 'nullable|string|max:255',
            'country'               => 'nullable|string|max:255',
            'primary_venue_name'    => 'nullable|string|max:255',
            'primary_venue_address' => 'nullable|string',
            'rsvp_deadline'         => 'nullable|date',
            'settings'              => 'nullable|array',
        ]);

        $wedding->update($data);

        return response()->json($wedding->fresh());
    }
}
