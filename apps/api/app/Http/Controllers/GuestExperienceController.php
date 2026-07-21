<?php

namespace App\Http\Controllers;

use App\Models\GuestExperienceConfig;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GuestExperienceController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManageExperience(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_guests'), 403);
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
        $this->ensureCanManageExperience($request);

        $data = $request->validate([
            'publish_state'           => 'nullable|string|in:draft,published,paused',
            'layout_order'            => 'nullable|array',
            'layout_order.*'          => 'string',
            'access_rules'            => 'nullable|array',
            'welcome_message'        => 'nullable|string',
            'dress_code'             => 'nullable|string|max:255',
            'show_schedule'          => 'nullable|boolean',
            'show_venue_map'         => 'nullable|boolean',
            'show_accommodation'     => 'nullable|boolean',
            'show_transport'         => 'nullable|boolean',
            'show_seating'           => 'nullable|boolean',
            'show_registry'          => 'nullable|boolean',
            'show_gallery'           => 'nullable|boolean',
            'show_live_feed'         => 'nullable|boolean',
            'allow_photo_uploads'    => 'nullable|boolean',
            'allow_messages'         => 'nullable|boolean',
            'rsvp_enabled'           => 'nullable|boolean',
            'meal_selection_enabled' => 'nullable|boolean',
            'plus_one_enabled'       => 'nullable|boolean',
            'dress_code_details'     => 'nullable|string',
            'cover_image_url'        => 'nullable|url',
            'theme_color'            => 'nullable|string|max:20',
        ]);

        if (($data['publish_state'] ?? null) === 'published') {
            $data['published_at'] = now();
        }

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
                'couple_names'  => trim(implode(' & ', array_filter([$wedding->couple_name_primary, $wedding->couple_name_secondary]))),
                'event_date'    => $wedding->event_date,
                'venue_name'    => $wedding->primary_venue_name,
                'venue_city'    => $wedding->city,
                'venue_country' => $wedding->country,
            ],
            'config' => $config,
        ]);
    }
}
