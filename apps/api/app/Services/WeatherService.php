<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WeatherService
{
    /**
     * Uses OpenWeatherMap's classic free-tier endpoints (current + 5
     * day/3 hour forecast) rather than One Call 3.0, which requires a
     * billing method on file even within its free allowance.
     */
    public function forecast(float $lat, float $lng): ?array
    {
        $key = env('OPENWEATHER_API_KEY');
        if (! $key) {
            return null;
        }

        $cacheKey = sprintf('weather:%.3f:%.3f', $lat, $lng);

        return Cache::remember($cacheKey, now()->addMinutes(30), function () use ($lat, $lng, $key) {
            try {
                $current = Http::get('https://api.openweathermap.org/data/2.5/weather', [
                    'lat' => $lat, 'lon' => $lng, 'appid' => $key, 'units' => 'imperial',
                ]);
                $forecast = Http::get('https://api.openweathermap.org/data/2.5/forecast', [
                    'lat' => $lat, 'lon' => $lng, 'appid' => $key, 'units' => 'imperial',
                ]);

                if (! $current->successful() || ! $forecast->successful()) {
                    Log::warning('Weather API request failed', [
                        'current_status' => $current->status(),
                        'forecast_status' => $forecast->status(),
                    ]);
                    return null;
                }

                $c = $current->json();
                $f = $forecast->json();

                return [
                    'temp'        => round($c['main']['temp']),
                    'feels_like'  => round($c['main']['feels_like']),
                    'condition'   => $c['weather'][0]['main'] ?? 'Clear',
                    'description' => $c['weather'][0]['description'] ?? '',
                    'humidity'    => $c['main']['humidity'],
                    'wind_mph'    => round($c['wind']['speed'] ?? 0),
                    'clouds_pct'  => $c['clouds']['all'] ?? 0,
                    'rain_chance_pct' => round((($f['list'][0]['pop'] ?? 0)) * 100),
                    'hourly' => collect($f['list'] ?? [])->take(5)->map(fn ($item) => [
                        'time'      => \Carbon\Carbon::parse($item['dt_txt'])->format('g:i A'),
                        'temp'      => round($item['main']['temp']),
                        'condition' => $item['weather'][0]['main'] ?? 'Clear',
                    ])->values()->all(),
                ];
            } catch (\Throwable $e) {
                Log::warning('Weather fetch failed', ['error' => $e->getMessage()]);
                return null;
            }
        });
    }
}
