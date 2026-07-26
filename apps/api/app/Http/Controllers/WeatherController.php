<?php

namespace App\Http\Controllers;

use App\Services\GeocodingService;
use App\Services\WeatherService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WeatherController extends Controller
{
    public function __construct(
        private GeocodingService $geocoder,
        private WeatherService $weather,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');

        if ($wedding->venue_lat === null || $wedding->venue_lng === null) {
            $address = trim(implode(', ', array_filter([
                $wedding->primary_venue_name,
                $wedding->primary_venue_address,
                $wedding->city,
                $wedding->country,
            ])));

            $coords = $address !== '' ? $this->geocoder->geocode($address) : null;

            if ($coords) {
                $wedding->update(['venue_lat' => $coords['lat'], 'venue_lng' => $coords['lng']]);
            }
        }

        if ($wedding->venue_lat === null || $wedding->venue_lng === null) {
            return response()->json([
                'data' => null,
                'message' => 'Add your venue address in Wedding settings to see local weather.',
            ]);
        }

        $forecast = $this->weather->forecast((float) $wedding->venue_lat, (float) $wedding->venue_lng, $wedding->event_date);

        if ($forecast === null) {
            return response()->json([
                'data' => null,
                'message' => 'Weather is temporarily unavailable.',
            ]);
        }

        return response()->json(['data' => $forecast]);
    }
}
