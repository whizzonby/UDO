<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class SpoonacularService
{
    private const BASE_URL = 'https://api.spoonacular.com';

    /**
     * Title-only suggestions for the type-as-you-go search field. This is
     * the cheap endpoint (0.1 points/call on Spoonacular's quota) so it's
     * safe to call on every keystroke; cached per query to avoid re-spending
     * quota on repeat searches across weddings.
     */
    public function autocomplete(string $query, int $number = 10): ?array
    {
        $key = config('services.spoonacular.key');
        if (! $key) {
            return null;
        }

        $cacheKey = sprintf('spoonacular:autocomplete:%s:%d', strtolower(trim($query)), $number);

        return Cache::remember($cacheKey, now()->addHours(6), function () use ($query, $number, $key) {
            try {
                $response = Http::get(self::BASE_URL . '/recipes/autocomplete', [
                    'query' => $query,
                    'number' => $number,
                    'apiKey' => $key,
                ]);

                if (! $response->successful()) {
                    Log::warning('Spoonacular autocomplete failed', ['status' => $response->status()]);
                    return null;
                }

                return collect($response->json())
                    ->map(fn ($item) => ['id' => $item['id'], 'title' => $item['title']])
                    ->values()
                    ->all();
            } catch (\Throwable $e) {
                Log::warning('Spoonacular autocomplete request failed', ['error' => $e->getMessage()]);
                return null;
            }
        });
    }

    /**
     * Full recipe details — only called once, when a suggestion is actually
     * picked (1 point/call). Cached indefinitely-ish (30 days) since a
     * recipe's core details don't change.
     */
    public function information(int $id): ?array
    {
        $key = config('services.spoonacular.key');
        if (! $key) {
            return null;
        }

        $cacheKey = "spoonacular:recipe:{$id}";

        return Cache::remember($cacheKey, now()->addDays(30), function () use ($id, $key) {
            try {
                $response = Http::get(self::BASE_URL . "/recipes/{$id}/information", [
                    'apiKey' => $key,
                ]);

                if (! $response->successful()) {
                    Log::warning('Spoonacular recipe information failed', ['status' => $response->status(), 'id' => $id]);
                    return null;
                }

                $data = $response->json();

                return [
                    'id' => $data['id'] ?? $id,
                    'title' => $data['title'] ?? null,
                    'image' => $data['image'] ?? null,
                    'cuisines' => $data['cuisines'] ?? [],
                    'dish_types' => $data['dishTypes'] ?? [],
                    'diets' => $data['diets'] ?? [],
                    'vegetarian' => (bool) ($data['vegetarian'] ?? false),
                    'vegan' => (bool) ($data['vegan'] ?? false),
                    'gluten_free' => (bool) ($data['glutenFree'] ?? false),
                    'dairy_free' => (bool) ($data['dairyFree'] ?? false),
                ];
            } catch (\Throwable $e) {
                Log::warning('Spoonacular recipe information request failed', ['error' => $e->getMessage(), 'id' => $id]);
                return null;
            }
        });
    }
}
