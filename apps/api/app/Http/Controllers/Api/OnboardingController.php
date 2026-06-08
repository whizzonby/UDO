<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Onboarding\StoreOnboardingRequest;
use App\Http\Resources\WeddingResource;
use App\Models\Wedding;
use App\Models\WeddingUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OnboardingController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->with('onboardingData')->latest()->first();

        if (! $wedding) {
            return response()->json(['onboarding' => null]);
        }

        return response()->json([
            'wedding'   => new WeddingResource($wedding),
            'onboarding' => $wedding->onboardingData,
        ]);
    }

    public function store(StoreOnboardingRequest $request): JsonResponse
    {
        $data = $request->validated();

        $wedding = DB::transaction(function () use ($data, $request) {
            $wedding = Wedding::create([
                'partner_one_name' => $data['partner_one_name'],
                'partner_two_name' => $data['partner_two_name'] ?? null,
                'wedding_date'     => $data['wedding_date'] ?? null,
                'date_not_set'     => $data['date_not_set'] ?? false,
                'guest_count_range'=> $data['guest_count_range'] ?? null,
                'total_budget'     => $data['total_budget'] ?? null,
                'currency'         => $data['currency'] ?? 'USD',
                'timezone'         => $data['timezone'] ?? 'UTC',
            ]);

            WeddingUser::create([
                'wedding_id' => $wedding->id,
                'user_id'    => $request->user()->id,
                'role'       => 'owner',
                'joined_at'  => now(),
            ]);

            $onboardingFields = array_filter(
                $data,
                fn ($key) => ! in_array($key, [
                    'partner_one_name', 'partner_two_name', 'wedding_date',
                    'date_not_set', 'guest_count_range', 'total_budget',
                    'currency', 'timezone',
                ]),
                ARRAY_FILTER_USE_KEY
            );

            $wedding->onboardingData()->create([
                ...$onboardingFields,
                'wedding_id'   => $wedding->id,
                'completed_at' => now(),
            ]);

            return $wedding;
        });

        return response()->json([
            'wedding'   => new WeddingResource($wedding->load('onboardingData')),
            'message'   => 'Wedding created successfully.',
        ], 201);
    }
}
