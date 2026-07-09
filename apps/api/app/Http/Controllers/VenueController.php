<?php

namespace App\Http\Controllers;

use App\Services\GeocodingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VenueController extends Controller
{
    public function __construct(private GeocodingService $geocoder) {}

    /**
     * Returns the venue's coordinates for the Map tab, geocoding the
     * address on first request and caching the result on the wedding
     * row so we don't re-hit Nominatim on every load.
     */
    public function location(Request $request): JsonResponse
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

        return response()->json(['data' => [
            'lat'          => $wedding->venue_lat !== null ? (float) $wedding->venue_lat : null,
            'lng'          => $wedding->venue_lng !== null ? (float) $wedding->venue_lng : null,
            'venue_name'   => $wedding->primary_venue_name,
            'venue_address' => $wedding->primary_venue_address,
            'resolved'     => $wedding->venue_lat !== null,
        ]]);
    }
}
