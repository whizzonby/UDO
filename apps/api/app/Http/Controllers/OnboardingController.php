<?php

namespace App\Http\Controllers;

use App\Models\OnboardingResponse;
use App\Models\Wedding;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OnboardingController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            // Identity / role
            'couple_name'              => 'nullable|string|max:255',
            'role'                     => 'required|string',
            'decision_style'           => 'nullable|string',
            'collaborators'            => 'nullable|array',
            'collaborators.*.name'     => 'nullable|string',
            'collaborators.*.email'    => 'nullable|email',
            'collaborators.*.role'     => 'nullable|string',

            // Planning structure
            'planning_approach'        => 'nullable|string',
            'planner_email'            => 'nullable|email',

            // Core event architecture
            'wedding_type'             => 'nullable|string',
            'season'                   => 'nullable|string',
            'date_status'              => 'nullable|string',
            'event_date'               => 'nullable|date',
            'time_of_day'              => 'nullable|string',
            'event_structure'          => 'nullable|array',

            // Location & travel
            'country'                  => 'nullable|string',
            'city'                     => 'nullable|string',
            'venue_status'             => 'nullable|string',
            'guest_travel'             => 'nullable|string',

            // Guest portal
            'guest_experience'         => 'nullable|array',
            'guest_count'              => 'nullable|integer',

            // Budget
            'total_budget'             => 'nullable|numeric',
            'budget_structure'         => 'nullable|string',
            'allocation_preference'    => 'nullable|string',
            'funding'                  => 'nullable|string',
            'budget_confidence'        => 'nullable|string',

            // Priorities
            'priorities'               => 'nullable|array',

            // Food & dining
            'dining_style'             => 'nullable|string',
            'dietary'                  => 'nullable|array',
            'dining_enhancements'      => 'nullable|array',

            // Vendors
            'core_vendors'             => 'nullable|array',
            'expanded_vendors'         => 'nullable|array',
            'unique_suppliers'         => 'nullable|array',

            // Wedding party
            'wedding_party'            => 'nullable|array',

            // Personal moments
            'speeches'                 => 'nullable|string',
            'who_speaking'             => 'nullable|array',
            'honouring_loved_ones'     => 'nullable|string',
            'tribute_type'             => 'nullable|string',
            'personal_touches'         => 'nullable|string',

            // Additional celebrations
            'additional_events'        => 'nullable|array',
            'event_organizer'          => 'nullable|string',

            // Cultural traditions module
            'cultural_celebration_type' => 'nullable|array',
            'cultural_traditions'      => 'nullable|array',
            'other_traditions'         => 'nullable|string',
            'religious_structure'      => 'nullable|array',
            'family_involvement'       => 'nullable|string',
            'shared_planning_access'   => 'nullable|string',
            'guest_hospitality'        => 'nullable|array',
            'attire_planning'          => 'nullable|array',
            'celebration_duration'     => 'nullable|string',
            'celebration_atmosphere'   => 'nullable|string',
            'planning_support_style'   => 'nullable|string',

            // Honeymoon
            'planning_honeymoon'       => 'nullable|string',
            'honeymoon_destination'    => 'nullable|string',
            'honeymoon_budget'         => 'nullable|numeric',
            'honeymoon_timing'         => 'nullable|string',

            // Insurance
            'insurance'                => 'nullable|string',
        ]);

        $user = $request->user();

        // Wedding.settings only holds the keys other parts of the app read
        // directly (HomeController/BudgetController read total_budget; the
        // Plan "Wedding Details" screen reads wedding_type/guest_count/
        // venue_status/planning_approach). The full questionnaire is
        // preserved verbatim in onboarding_responses for support/debugging
        // and future "edit your answers" flows, rather than being narrowed
        // to a fixed whitelist. array_filter drops unanswered questions so a
        // repeat/partial onboarding submission can't null out values that
        // were already set.
        $settings = array_filter([
            'total_budget'      => $data['total_budget'] ?? null,
            'wedding_type'      => $data['wedding_type'] ?? null,
            'guest_count'       => $data['guest_count'] ?? null,
            'venue_status'      => $data['venue_status'] ?? null,
            'planning_approach' => $data['planning_approach'] ?? null,
        ], fn ($value) => $value !== null);

        if (! $user->active_wedding_id) {
            $wedding = Wedding::create([
                'slug'                => Str::slug(($data['couple_name'] ?? $user->first_name) . '-wedding') . '-' . Str::random(6),
                'couple_name_primary' => $data['couple_name'] ?? ($user->first_name . ' & Partner'),
                'event_date'          => $data['event_date'] ?? null,
                'city'                => $data['city'] ?? null,
                'country'             => $data['country'] ?? null,
                'owner_user_id'       => $user->id,
                'settings'            => $settings,
            ]);

            $user->update([
                'active_wedding_id'    => $wedding->id,
                'onboarding_completed' => true,
            ]);
        } else {
            $wedding = $user->activeWedding;
            $existingSettings = $wedding->settings ?? [];
            $wedding->update([
                'couple_name_primary' => $data['couple_name'] ?? $wedding->couple_name_primary,
                'event_date'          => $data['event_date'] ?? $wedding->event_date,
                'city'                => $data['city'] ?? $wedding->city,
                'country'             => $data['country'] ?? $wedding->country,
                'settings'            => array_merge($existingSettings, $settings),
            ]);
            $user->update(['onboarding_completed' => true]);
        }

        OnboardingResponse::create([
            'user_id'    => $user->id,
            'wedding_id' => $wedding->id,
            'responses'  => $data,
        ]);

        return response()->json([
            'message'    => 'Onboarding complete.',
            'wedding_id' => $user->active_wedding_id,
        ]);
    }
}
