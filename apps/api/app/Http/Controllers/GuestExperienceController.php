<?php

namespace App\Http\Controllers;

use App\Models\GuestExperienceConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestExperienceController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function show(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $config = $wedding->experienceConfig ?? $wedding->experienceConfig()->create([]);
        return response()->json(['data' => $config]);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'welcome_message'        => 'nullable|string',
            'dress_code'             => 'nullable|string|max:255',
            'show_schedule'          => 'nullable|boolean',
            'show_venue_map'         => 'nullable|boolean',
            'show_accommodation'     => 'nullable|boolean',
            'show_transport'         => 'nullable|boolean',
            'show_registry'          => 'nullable|boolean',
            'show_gallery'           => 'nullable|boolean',
            'show_live_feed'         => 'nullable|boolean',
            'show_seat_info'         => 'nullable|boolean',
            'show_meal_selection'    => 'nullable|boolean',
            'rsvp_enabled'           => 'nullable|boolean',
            'rsvp_deadline'          => 'nullable|date',
            'meal_selection_enabled' => 'nullable|boolean',
            'plus_one_enabled'       => 'nullable|boolean',
            'custom_css'             => 'nullable|string',
            'cover_image_url'        => 'nullable|url',
            'theme_color'            => 'nullable|string|max:20',
        ]);

        $config = $wedding->experienceConfig()->updateOrCreate(
            ['wedding_id' => $wedding->id],
            $data
        );

        return response()->json(['data' => $config]);
    }

    public function preview(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $config  = $wedding->experienceConfig;

        return response()->json([
            'wedding' => [
                'couple_names' => $wedding->couple_names,
                'event_date'   => $wedding->event_date,
                'venue_name'   => $wedding->venue_name,
                'venue_city'   => $wedding->venue_city,
                'venue_country' => $wedding->venue_country,
            ],
            'config' => $config,
        ]);
    }
}
