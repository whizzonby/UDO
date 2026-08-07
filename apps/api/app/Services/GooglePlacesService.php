<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GooglePlacesService
{
    private const BASE_URL = 'https://maps.googleapis.com/maps/api/place';

    /**
     * Lodging-only suggestions for the type-as-you-go hotel name field.
     * Never cached: Google's Places ToS treats Autocomplete predictions as
     * short-lived and ties billing to the caller-supplied session token, so
     * every keystroke has to reach Google directly.
     */
    public function autocomplete(string $query, ?string $sessionToken = null, ?string $type = null): ?array
    {
        $key = config('services.google_places.key');
        if (! $key) {
            return null;
        }

        try {
            $response = Http::get(self::BASE_URL . '/autocomplete/json', array_filter([
                'input' => $query,
                'types' => $type,
                'key' => $key,
                'sessiontoken' => $sessionToken,
            ]));

            if (! $response->successful()) {
                Log::warning('Google Places autocomplete failed', ['status' => $response->status()]);
                return null;
            }

            $body = $response->json();
            $status = $body['status'] ?? null;

            if (! in_array($status, ['OK', 'ZERO_RESULTS'], true)) {
                Log::warning('Google Places autocomplete error status', ['status' => $status]);
                return null;
            }

            return collect($body['predictions'] ?? [])
                ->map(fn ($p) => [
                    'place_id' => $p['place_id'],
                    'name' => $p['structured_formatting']['main_text'] ?? $p['description'],
                    'address' => $p['structured_formatting']['secondary_text'] ?? null,
                    'description' => $p['description'] ?? null,
                ])
                ->values()
                ->all();
        } catch (\Throwable $e) {
            Log::warning('Google Places autocomplete request failed', ['error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Full place details — only called once, when a suggestion is picked.
     * Passing the same session token as the autocomplete call groups the
     * two into Google's cheaper per-session billing. Cached for 30 days
     * (Google's Places ToS allows caching Place details, unlike
     * predictions), since a hotel's address/phone rarely changes.
     */
    public function details(string $placeId, ?string $sessionToken = null): ?array
    {
        $key = config('services.google_places.key');
        if (! $key) {
            return null;
        }

        $cacheKey = "google_places:details:{$placeId}";

        return Cache::remember($cacheKey, now()->addDays(30), function () use ($placeId, $sessionToken, $key) {
            try {
                $response = Http::get(self::BASE_URL . '/details/json', array_filter([
                    'place_id' => $placeId,
                    'fields' => 'name,formatted_address,formatted_phone_number,international_phone_number',
                    'key' => $key,
                    'sessiontoken' => $sessionToken,
                ]));

                if (! $response->successful()) {
                    Log::warning('Google Places details failed', ['status' => $response->status()]);
                    return null;
                }

                $body = $response->json();
                if (($body['status'] ?? null) !== 'OK') {
                    Log::warning('Google Places details error status', ['status' => $body['status'] ?? null]);
                    return null;
                }

                $result = $body['result'] ?? [];

                return [
                    'place_id' => $placeId,
                    'name' => $result['name'] ?? null,
                    'address' => $result['formatted_address'] ?? null,
                    'phone' => $result['formatted_phone_number'] ?? $result['international_phone_number'] ?? null,
                ];
            } catch (\Throwable $e) {
                Log::warning('Google Places details request failed', ['error' => $e->getMessage()]);
                return null;
            }
        });
    }
}
