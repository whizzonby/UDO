<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeocodingService
{
    /**
     * Geocode a free-text address via OpenStreetMap's Nominatim — free,
     * no API key, but rate-limited to ~1 req/sec and requires a
     * descriptive User-Agent per their usage policy.
     */
    public function geocode(string $address): ?array
    {
        if (trim($address) === '') {
            return null;
        }

        try {
            $response = Http::withHeaders([
                'User-Agent' => 'UdoWeddingApp/1.0 (https://udowedding.app)',
            ])->get('https://nominatim.openstreetmap.org/search', [
                'q'      => $address,
                'format' => 'json',
                'limit'  => 1,
            ]);

            if (! $response->successful()) {
                return null;
            }

            $results = $response->json();
            if (empty($results)) {
                return null;
            }

            return [
                'lat' => (float) $results[0]['lat'],
                'lng' => (float) $results[0]['lon'],
            ];
        } catch (\Throwable $e) {
            Log::warning('Geocoding failed', ['address' => $address, 'error' => $e->getMessage()]);
            return null;
        }
    }
}
