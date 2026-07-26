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
     *
     * $weddingDate is optional — when supplied, a `wedding_day` forecast is
     * only populated if the date actually falls within the 5-day/3-hour
     * window the free tier covers. A wedding months away has no real
     * forecast yet, so we say so rather than fabricate one.
     */
    public function forecast(float $lat, float $lng, ?\DateTimeInterface $weddingDate = null): ?array
    {
        $key = env('OPENWEATHER_API_KEY');
        if (! $key) {
            return null;
        }

        $cacheKey = sprintf('weather:%.3f:%.3f', $lat, $lng);

        $base = Cache::remember($cacheKey, now()->addMinutes(30), function () use ($lat, $lng, $key) {
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
                $tzOffsetSeconds = $c['timezone'] ?? 0;

                return [
                    'temp'        => round($c['main']['temp']),
                    'feels_like'  => round($c['main']['feels_like']),
                    'condition'   => $c['weather'][0]['main'] ?? 'Clear',
                    'description' => $c['weather'][0]['description'] ?? '',
                    'humidity'    => $c['main']['humidity'],
                    'wind_mph'    => round($c['wind']['speed'] ?? 0),
                    'clouds_pct'  => $c['clouds']['all'] ?? 0,
                    'rain_chance_pct' => round((($f['list'][0]['pop'] ?? 0)) * 100),
                    'sunset'      => isset($c['sys']['sunset'])
                        ? \Carbon\Carbon::createFromTimestampUTC($c['sys']['sunset'])->addSeconds($tzOffsetSeconds)->format('g:i A')
                        : null,
                    'hourly' => collect($f['list'] ?? [])->take(5)->map(fn ($item) => [
                        'time'      => \Carbon\Carbon::parse($item['dt_txt'])->format('g:i A'),
                        'temp'      => round($item['main']['temp']),
                        'condition' => $item['weather'][0]['main'] ?? 'Clear',
                    ])->values()->all(),
                    // Kept raw so wedding-day matching can run outside the cached closure
                    // (the closure only re-executes every 30 minutes; the wedding date match
                    // below must be evaluated on every request).
                    '_forecast_list' => $f['list'] ?? [],
                ];
            } catch (\Throwable $e) {
                Log::warning('Weather fetch failed', ['error' => $e->getMessage()]);
                return null;
            }
        });

        if ($base === null) {
            return null;
        }

        $forecastList = $base['_forecast_list'];
        unset($base['_forecast_list']);

        $base['wedding_day'] = $weddingDate
            ? $this->matchWeddingDayForecast($forecastList, $weddingDate)
            : null;

        return $base;
    }

    /**
     * The free-tier forecast only covers ~5 days out. Return null (with
     * forecast_available: false) when the wedding date is further out than
     * that, instead of guessing.
     */
    private function matchWeddingDayForecast(array $forecastList, \DateTimeInterface $weddingDate): array
    {
        $targetDate = \Carbon\Carbon::instance($weddingDate)->startOfDay();

        $dayEntries = collect($forecastList)->filter(function ($item) use ($targetDate) {
            return \Carbon\Carbon::parse($item['dt_txt'])->isSameDay($targetDate);
        });

        if ($dayEntries->isEmpty()) {
            return ['forecast_available' => false];
        }

        // Prefer the entry closest to midday for a representative "wedding day" reading.
        $midday = $dayEntries->sortBy(function ($item) use ($targetDate) {
            return abs(\Carbon\Carbon::parse($item['dt_txt'])->diffInMinutes($targetDate->copy()->setTime(12, 0)));
        })->first();

        return [
            'forecast_available' => true,
            'temp'        => round($midday['main']['temp']),
            'condition'   => $midday['weather'][0]['main'] ?? 'Clear',
            'description' => $midday['weather'][0]['description'] ?? '',
            'rain_chance_pct' => round(($midday['pop'] ?? 0) * 100),
        ];
    }
}
