<?php

namespace App\Http\Controllers;

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

        $forecast['timeline_risks'] = $this->timelineWeatherRisks(
            $wedding,
            $forecast['wedding_day']['hourly'] ?? [],
        );

        return response()->json(['data' => $forecast]);
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
