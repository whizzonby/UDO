<?php

namespace App\Http\Controllers;

use App\Models\OnboardingResponse;
use App\Services\GeocodingService;
use App\Services\WeatherService;
use Carbon\Carbon;
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

        [$resolved, $hadLocationInput] = $this->resolveWeatherLocation($wedding);

        if ($resolved === null) {
            return response()->json([
                'data' => null,
                'message' => $hadLocationInput
                    ? 'We found venue details, but could not match them to a weather location. Add a full venue address, city, and country.'
                    : 'Add a city/country, venue address, or timeline location to see local weather.',
            ]);
        }

        $forecast = $this->weather->forecast((float) $resolved['lat'], (float) $resolved['lng'], $wedding->event_date);

        if ($forecast === null) {
            return response()->json([
                'data' => null,
                'message' => 'Weather is temporarily unavailable.',
            ]);
        }

        $forecast['location_label'] = $resolved['label'];
        $forecast['timeline_risks'] = $this->timelineWeatherRisks(
            $wedding,
            $forecast['wedding_day']['hourly'] ?? [],
        );

        return response()->json(['data' => $forecast]);
    }

    private function resolveWeatherLocation($wedding): array
    {
        if ($wedding->venue_lat !== null && $wedding->venue_lng !== null) {
            return [
                [
                    'lat' => (float) $wedding->venue_lat,
                    'lng' => (float) $wedding->venue_lng,
                    'label' => $wedding->primary_venue_name ?: $wedding->city ?: 'Wedding venue',
                ],
                true,
            ];
        }

        $candidates = $this->candidateLocationLabels($wedding);

        foreach ($candidates as $label) {
            $coords = $this->geocoder->geocode($label)
                ?? $this->weather->geocode($label);
            if ($coords) {
                $wedding->update(['venue_lat' => $coords['lat'], 'venue_lng' => $coords['lng']]);
                return [
                    [
                        'lat' => (float) $coords['lat'],
                        'lng' => (float) $coords['lng'],
                        'label' => $this->locationLabel($wedding, $label),
                    ],
                    true,
                ];
            }
        }

        return [null, ! empty($candidates)];
    }

    private function candidateLocationLabels($wedding): array
    {
        $settings = $wedding->settings ?? [];
        $cityCountry = $this->joinLocationParts([
            $wedding->city,
            $wedding->country,
            $settings['city'] ?? null,
            $settings['country'] ?? null,
            $this->latestOnboardingValue($wedding, 'city'),
            $this->latestOnboardingValue($wedding, 'country'),
        ]);
        $labels = [];

        $directParts = [
            [$wedding->primary_venue_name, $wedding->primary_venue_address, $cityCountry],
            [$wedding->primary_venue_address, $cityCountry],
            [$wedding->primary_venue_name, $cityCountry],
            [$settings['primary_venue_name'] ?? null, $settings['primary_venue_address'] ?? null, $cityCountry],
            [$settings['venue_name'] ?? null, $settings['venue_address'] ?? null, $cityCountry],
            [$settings['ceremony_venue'] ?? null, $settings['ceremony_venue_address'] ?? null, $cityCountry],
            [$settings['reception_venue_name'] ?? null, $settings['reception_venue_address'] ?? null, $cityCountry],
            [$settings['wedding_location'] ?? null, $cityCountry],
            [$settings['location'] ?? null, $cityCountry],
            [$cityCountry],
        ];

        foreach ($directParts as $parts) {
            $label = $this->joinLocationParts($parts);
            if ($label !== '') {
                $labels[] = $label;
            }
        }

        $wedding->timelineItems()
            ->orderBy('event_date')
            ->orderBy('start_time')
            ->get(['location', 'location_address'])
            ->each(function ($item) use (&$labels, $cityCountry) {
                foreach ([$item->location_address, $item->location] as $location) {
                    $location = trim((string) $location);
                    if ($location !== '') {
                        $labels[] = $cityCountry !== '' && ! str_contains(strtolower($location), strtolower($cityCountry))
                            ? "{$location}, {$cityCountry}"
                            : $location;
                    }
                }
            });

        $wedding->weddingWeekendEvents()
            ->whereNotNull('location')
            ->orderBy('event_date')
            ->orderBy('start_time')
            ->pluck('location')
            ->each(function ($location) use (&$labels, $cityCountry) {
                $location = trim((string) $location);
                if ($location !== '') {
                    $labels[] = $cityCountry !== '' && ! str_contains(strtolower($location), strtolower($cityCountry))
                        ? "{$location}, {$cityCountry}"
                        : $location;
                }
            });

        return array_values(array_unique($labels));
    }

    private function joinLocationParts(array $parts): string
    {
        $clean = array_filter(array_map(function ($value) {
            $value = is_scalar($value) ? trim((string) $value) : '';
            return $value !== '' ? $value : null;
        }, $parts));

        return trim(implode(', ', array_values(array_unique($clean))));
    }

    private function locationLabel($wedding, string $fallback): string
    {
        return $wedding->primary_venue_name
            ?: $this->setting($wedding, 'reception_venue_name')
            ?: $this->setting($wedding, 'venue_name')
            ?: $wedding->city
            ?: $fallback;
    }

    private function setting($wedding, string $key): ?string
    {
        $value = ($wedding->settings ?? [])[$key] ?? null;
        return is_string($value) && trim($value) !== '' ? trim($value) : null;
    }

    private function latestOnboardingValue($wedding, string $key): ?string
    {
        $record = OnboardingResponse::query()
            ->where('wedding_id', $wedding->id)
            ->latest()
            ->first(['responses']);

        $responses = $record?->responses ?? [];
        $value = is_array($responses) ? ($responses[$key] ?? null) : null;

        return is_string($value) && trim($value) !== '' ? trim($value) : null;
    }

    private function timelineWeatherRisks($wedding, array $hourly): array
    {
        if (! $wedding->event_date || empty($hourly)) {
            return [];
        }

        return $wedding->timelineItems()
            ->whereDate('event_date', $wedding->event_date->toDateString())
            ->get()
            ->map(fn ($item) => $this->timelineItemWeatherRisk($item, $hourly))
            ->filter()
            ->values()
            ->all();
    }

    private function timelineItemWeatherRisk($item, array $hourly): ?array
    {
        if (! $item->start_time) {
            return null;
        }

        $start = Carbon::parse($item->event_date->toDateString() . ' ' . $item->start_time);
        $end = $item->end_time
            ? Carbon::parse($item->event_date->toDateString() . ' ' . $item->end_time)
            : $start->copy()->addMinutes((int) ($item->duration_minutes ?? 90));
        $windowStart = $start->copy()->subMinutes(45);
        $windowEnd = $end->copy()->addMinutes(45);

        $matches = collect($hourly)->filter(function ($entry) use ($windowStart, $windowEnd) {
            if (empty($entry['at'])) {
                return false;
            }
            $at = Carbon::parse($entry['at']);
            return $at->betweenIncluded($windowStart, $windowEnd);
        });

        if ($matches->isEmpty()) {
            return null;
        }

        $maxRain = (int) $matches->max('rain_chance_pct');
        $maxWind = (int) $matches->max('wind_mph');
        $outdoor = $this->looksOutdoor($item);
        $rainRisk = $maxRain >= ($outdoor ? 35 : 65);
        $windRisk = $maxWind >= ($outdoor ? 16 : 24);

        if (! $rainRisk && ! $windRisk) {
            return null;
        }

        $riskType = $rainRisk ? 'rain' : 'wind';
        $value = $rainRisk ? "{$maxRain}% chance of rain" : "{$maxWind} mph wind";
        $severity = ($rainRisk && $maxRain >= 60) || ($windRisk && $maxWind >= 22)
            ? 'high'
            : 'monitor';

        return [
            'event_id' => $item->id,
            'event_title' => $item->title,
            'location' => $item->location,
            'starts_at' => $start->toIso8601String(),
            'risk_type' => $riskType,
            'severity' => $severity,
            'forecast_value' => $value,
            'message' => "Monitor weather: {$item->title} is scheduled around {$start->format('g:i A')}" .
                (($item->location ?? '') !== '' ? " at {$item->location}" : '') .
                ", and the forecast shows {$value}. This is a forecast and is subject to change.",
        ];
    }

    private function looksOutdoor($item): bool
    {
        $text = strtolower(implode(' ', array_filter([
            $item->title,
            $item->event_type,
            $item->location,
            $item->description,
            $item->notes,
        ])));

        foreach (['outdoor', 'garden', 'terrace', 'beach', 'lawn', 'patio', 'courtyard', 'pool', 'rooftop', 'park', 'field'] as $keyword) {
            if (str_contains($text, $keyword)) {
                return true;
            }
        }

        return false;
    }
}
