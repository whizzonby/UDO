<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WeatherService
{
    public function geocode(string $location): ?array
    {
        $key = config('services.openweather.key');
        $location = trim($location);
        if (! $key || $location === '') {
            return null;
        }

        try {
            $response = Http::timeout(15)->get('https://api.openweathermap.org/geo/1.0/direct', [
                'q' => $location,
                'limit' => 1,
                'appid' => $key,
            ]);

            if (! $response->successful()) {
                Log::warning('OpenWeather geocoding request failed', [
                    'status' => $response->status(),
                    'location_hash' => hash('sha256', strtolower($location)),
                ]);
                return null;
            }

            $result = $response->json('0');
            if (! is_array($result) || ! isset($result['lat'], $result['lon'])) {
                return null;
            }

            return [
                'lat' => (float) $result['lat'],
                'lng' => (float) $result['lon'],
            ];
        } catch (\Throwable $e) {
            Log::warning('OpenWeather geocoding failed', [
                'location_hash' => hash('sha256', strtolower($location)),
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

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
        return $this->openMeteoForecast($lat, $lng, $weddingDate)
            ?? $this->openWeatherForecast($lat, $lng, $weddingDate);
    }

    private function openMeteoForecast(float $lat, float $lng, ?\DateTimeInterface $weddingDate = null): ?array
    {
        $cacheKey = sprintf('weather:openmeteo:%.3f:%.3f', $lat, $lng);

        $base = Cache::remember($cacheKey, now()->addMinutes(30), function () use ($lat, $lng) {
            try {
                $response = Http::timeout(20)->get('https://api.open-meteo.com/v1/forecast', [
                    'latitude' => $lat,
                    'longitude' => $lng,
                    'current' => 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,cloud_cover,wind_speed_10m',
                    'hourly' => 'temperature_2m,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m,cloud_cover',
                    'daily' => 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,sunset',
                    'forecast_days' => 16,
                    'temperature_unit' => 'fahrenheit',
                    'wind_speed_unit' => 'mph',
                    'timezone' => 'auto',
                ]);

                if (! $response->successful()) {
                    Log::warning('Open-Meteo request failed', ['status' => $response->status()]);
                    return null;
                }

                $body = $response->json();
                $current = $body['current'] ?? [];
                $hourly = $body['hourly'] ?? [];
                $daily = $body['daily'] ?? [];
                $code = (int) ($current['weather_code'] ?? 0);

                return [
                    'provider' => 'open_meteo',
                    'temp' => isset($current['temperature_2m']) ? round($current['temperature_2m']) : null,
                    'feels_like' => isset($current['apparent_temperature']) ? round($current['apparent_temperature']) : null,
                    'condition' => $this->weatherCodeLabel($code),
                    'description' => $this->weatherCodeDescription($code),
                    'humidity' => $current['relative_humidity_2m'] ?? null,
                    'wind_mph' => isset($current['wind_speed_10m']) ? round($current['wind_speed_10m']) : null,
                    'clouds_pct' => $current['cloud_cover'] ?? null,
                    'rain_chance_pct' => $hourly['precipitation_probability'][0] ?? null,
                    'sunset' => isset($daily['sunset'][0]) ? \Carbon\Carbon::parse($daily['sunset'][0])->format('g:i A') : null,
                    'hourly' => $this->openMeteoHourly($hourly, 5),
                    '_hourly' => $hourly,
                    '_daily' => $daily,
                ];
            } catch (\Throwable $e) {
                Log::warning('Open-Meteo fetch failed', ['error' => $e->getMessage()]);
                return null;
            }
        });

        if ($base === null) {
            return null;
        }

        $hourly = $base['_hourly'];
        $daily = $base['_daily'];
        unset($base['_hourly'], $base['_daily']);

        $base['wedding_day'] = $weddingDate
            ? $this->matchOpenMeteoWeddingDayForecast($hourly, $daily, $weddingDate)
            : [
                'forecast_available' => false,
                'reason' => 'Add your wedding date to see the wedding-day forecast.',
            ];

        return $base;
    }

    private function openWeatherForecast(float $lat, float $lng, ?\DateTimeInterface $weddingDate = null): ?array
    {
        $key = config('services.openweather.key');
        if (! $key) {
            Log::warning('OpenWeather API key is missing.');
            return null;
        }

        $cacheKey = sprintf('weather:openweather:%.3f:%.3f', $lat, $lng);

        $base = Cache::remember($cacheKey, now()->addMinutes(30), function () use ($lat, $lng, $key) {
            try {
                $current = Http::timeout(20)->get('https://api.openweathermap.org/data/2.5/weather', [
                    'lat' => $lat, 'lon' => $lng, 'appid' => $key, 'units' => 'imperial',
                ]);
                $forecast = Http::timeout(20)->get('https://api.openweathermap.org/data/2.5/forecast', [
                    'lat' => $lat, 'lon' => $lng, 'appid' => $key, 'units' => 'imperial',
                ]);

                if (! $current->successful() || ! $forecast->successful()) {
                    Log::warning('Weather API request failed', [
                        'current_status' => $current->status(),
                        'forecast_status' => $forecast->status(),
                        'current_error' => $current->json('message'),
                        'forecast_error' => $forecast->json('message'),
                    ]);
                    return null;
                }

                $c = $current->json();
                $f = $forecast->json();
                $tzOffsetSeconds = $c['timezone'] ?? 0;

                return [
                    'provider'    => 'open_weather',
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
                        'at'        => $item['dt_txt'] ?? null,
                        'time'      => \Carbon\Carbon::parse($item['dt_txt'])->format('g:i A'),
                        'temp'      => round($item['main']['temp']),
                        'condition' => $item['weather'][0]['main'] ?? 'Clear',
                        'rain_chance_pct' => round(($item['pop'] ?? 0) * 100),
                        'wind_mph' => round($item['wind']['speed'] ?? 0),
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
            : [
                'forecast_available' => false,
                'reason' => 'Add your wedding date to see the wedding-day forecast.',
            ];

        return $base;
    }

    private function openMeteoHourly(array $hourly, int $limit): array
    {
        $times = $hourly['time'] ?? [];
        $temperatures = $hourly['temperature_2m'] ?? [];
        $codes = $hourly['weather_code'] ?? [];
        $rain = $hourly['precipitation_probability'] ?? [];
        $wind = $hourly['wind_speed_10m'] ?? [];

        return collect($times)->take($limit)->values()->map(function ($time, $index) use ($temperatures, $codes, $rain, $wind) {
            $code = (int) ($codes[$index] ?? 0);
            return [
                'at' => $time,
                'time' => \Carbon\Carbon::parse($time)->format('g:i A'),
                'temp' => isset($temperatures[$index]) ? round($temperatures[$index]) : null,
                'condition' => $this->weatherCodeLabel($code),
                'rain_chance_pct' => $rain[$index] ?? null,
                'wind_mph' => isset($wind[$index]) ? round($wind[$index]) : null,
            ];
        })->all();
    }

    private function matchOpenMeteoWeddingDayForecast(array $hourly, array $daily, \DateTimeInterface $weddingDate): array
    {
        $targetDate = \Carbon\Carbon::instance($weddingDate)->startOfDay();
        $targetDateString = $targetDate->toDateString();
        $dailyDates = $daily['time'] ?? [];
        $dailyIndex = array_search($targetDateString, $dailyDates, true);

        if ($dailyIndex === false) {
            return [
                'forecast_available' => false,
                'date' => $targetDateString,
                'reason' => 'Forecast available closer to the wedding date.',
            ];
        }

        $times = $hourly['time'] ?? [];
        $temperatures = $hourly['temperature_2m'] ?? [];
        $humidity = $hourly['relative_humidity_2m'] ?? [];
        $rain = $hourly['precipitation_probability'] ?? [];
        $wind = $hourly['wind_speed_10m'] ?? [];
        $clouds = $hourly['cloud_cover'] ?? [];
        $codes = $hourly['weather_code'] ?? [];

        $dayIndexes = collect($times)->keys()->filter(fn ($index) =>
            str_starts_with((string) ($times[$index] ?? ''), $targetDateString)
        )->values();

        $hourlyRows = $dayIndexes->map(function ($index) use ($times, $temperatures, $codes, $rain, $wind) {
            $code = (int) ($codes[$index] ?? 0);
            return [
                'at' => $times[$index] ?? null,
                'time' => isset($times[$index]) ? \Carbon\Carbon::parse($times[$index])->format('g:i A') : null,
                'temp' => isset($temperatures[$index]) ? round($temperatures[$index]) : null,
                'condition' => $this->weatherCodeLabel($code),
                'rain_chance_pct' => $rain[$index] ?? null,
                'wind_mph' => isset($wind[$index]) ? round($wind[$index]) : null,
            ];
        })->values();

        $middayIndex = $dayIndexes->sortBy(function ($index) use ($times, $targetDate) {
            return isset($times[$index])
                ? abs(\Carbon\Carbon::parse($times[$index])->diffInMinutes($targetDate->copy()->setTime(12, 0)))
                : PHP_INT_MAX;
        })->first();

        $code = (int) ($codes[$middayIndex] ?? ($daily['weather_code'][$dailyIndex] ?? 0));

        return [
            'forecast_available' => true,
            'date' => $targetDateString,
            'temp' => isset($temperatures[$middayIndex]) ? round($temperatures[$middayIndex]) : null,
            'temp_min' => isset($daily['temperature_2m_min'][$dailyIndex]) ? round($daily['temperature_2m_min'][$dailyIndex]) : null,
            'temp_max' => isset($daily['temperature_2m_max'][$dailyIndex]) ? round($daily['temperature_2m_max'][$dailyIndex]) : null,
            'condition' => $this->weatherCodeLabel($code),
            'description' => $this->weatherCodeDescription($code),
            'rain_chance_pct' => $daily['precipitation_probability_max'][$dailyIndex] ?? null,
            'wind_mph' => isset($daily['wind_speed_10m_max'][$dailyIndex]) ? round($daily['wind_speed_10m_max'][$dailyIndex]) : null,
            'humidity' => $dayIndexes->isNotEmpty() ? (int) round($dayIndexes->avg(fn ($index) => $humidity[$index] ?? 0)) : null,
            'clouds_pct' => $dayIndexes->isNotEmpty() ? (int) round($dayIndexes->avg(fn ($index) => $clouds[$index] ?? 0)) : null,
            'hourly' => $hourlyRows->all(),
        ];
    }

    private function weatherCodeLabel(int $code): string
    {
        return match (true) {
            $code === 0 => 'Clear',
            in_array($code, [1, 2, 3], true) => 'Clouds',
            in_array($code, [45, 48], true) => 'Fog',
            in_array($code, [51, 53, 55, 56, 57], true) => 'Drizzle',
            in_array($code, [61, 63, 65, 66, 67, 80, 81, 82], true) => 'Rain',
            in_array($code, [71, 73, 75, 77, 85, 86], true) => 'Snow',
            in_array($code, [95, 96, 99], true) => 'Thunderstorm',
            default => 'Weather',
        };
    }

    private function weatherCodeDescription(int $code): string
    {
        return match ($code) {
            0 => 'clear sky',
            1 => 'mainly clear',
            2 => 'partly cloudy',
            3 => 'overcast',
            45, 48 => 'fog',
            51, 53, 55 => 'drizzle',
            56, 57 => 'freezing drizzle',
            61, 63, 65 => 'rain',
            66, 67 => 'freezing rain',
            71, 73, 75 => 'snowfall',
            77 => 'snow grains',
            80, 81, 82 => 'rain showers',
            85, 86 => 'snow showers',
            95 => 'thunderstorm',
            96, 99 => 'thunderstorm with hail',
            default => 'forecast',
        };
    }

    /**
     * The free-tier forecast only covers ~5 days out. Return null (with
     * forecast_available: false) when the wedding date is further out than
     * that, instead of guessing.
     */
    private function matchWeddingDayForecast(array $forecastList, \DateTimeInterface $weddingDate): array
    {
        $targetDate = \Carbon\Carbon::instance($weddingDate)->startOfDay();
        $targetDateString = $targetDate->toDateString();

        $dayEntries = collect($forecastList)->filter(function ($item) use ($targetDate) {
            return \Carbon\Carbon::parse($item['dt_txt'])->isSameDay($targetDate);
        });

        if ($dayEntries->isEmpty()) {
            return [
                'forecast_available' => false,
                'date' => $targetDateString,
                'reason' => 'Forecast available closer to the wedding date.',
            ];
        }

        // Prefer the entry closest to midday for a representative "wedding day" reading.
        $midday = $dayEntries->sortBy(function ($item) use ($targetDate) {
            return abs(\Carbon\Carbon::parse($item['dt_txt'])->diffInMinutes($targetDate->copy()->setTime(12, 0)));
        })->first();

        $temps = $dayEntries->map(fn ($item) => $item['main']['temp'] ?? null)->filter();
        $rainChance = $dayEntries->max(fn ($item) => $item['pop'] ?? 0);
        $wind = $dayEntries->max(fn ($item) => $item['wind']['speed'] ?? 0);
        $humidity = (int) round($dayEntries->avg(fn ($item) => $item['main']['humidity'] ?? 0));
        $clouds = (int) round($dayEntries->avg(fn ($item) => $item['clouds']['all'] ?? 0));

        return [
            'forecast_available' => true,
            'date' => $targetDateString,
            'temp'        => round($midday['main']['temp']),
            'temp_min'    => $temps->isNotEmpty() ? round($temps->min()) : null,
            'temp_max'    => $temps->isNotEmpty() ? round($temps->max()) : null,
            'condition'   => $midday['weather'][0]['main'] ?? 'Clear',
            'description' => $midday['weather'][0]['description'] ?? '',
            'rain_chance_pct' => round($rainChance * 100),
            'wind_mph' => round($wind),
            'humidity' => $humidity,
            'clouds_pct' => $clouds,
            'hourly' => $dayEntries->map(fn ($item) => [
                'at'        => $item['dt_txt'] ?? null,
                'time'      => \Carbon\Carbon::parse($item['dt_txt'])->format('g:i A'),
                'temp'      => round($item['main']['temp']),
                'condition' => $item['weather'][0]['main'] ?? 'Clear',
                'rain_chance_pct' => round(($item['pop'] ?? 0) * 100),
                'wind_mph' => round($item['wind']['speed'] ?? 0),
            ])->values()->all(),
        ];
    }
}
