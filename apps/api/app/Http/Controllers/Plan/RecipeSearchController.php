<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Services\SpoonacularService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecipeSearchController extends Controller
{
    public function __construct(private SpoonacularService $spoonacular) {}

    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    public function search(Request $request): JsonResponse
    {
        $this->wedding($request);

        $data = $request->validate([
            'query' => 'required|string|max:255',
        ]);

        $results = $this->spoonacular->autocomplete($data['query']);

        if ($results === null) {
            return response()->json(['data' => [], 'message' => 'Recipe search is not configured yet.']);
        }

        return response()->json(['data' => $results]);
    }

    public function show(Request $request, int $recipeId): JsonResponse
    {
        $this->wedding($request);

        $recipe = $this->spoonacular->information($recipeId);

        if ($recipe === null) {
            return response()->json(['data' => null, 'message' => 'Recipe details are not available.']);
        }

        return response()->json(['data' => $recipe]);
    }
}
