<?php

namespace App\Http\Controllers;

use App\Services\GooglePlacesService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlaceSearchController extends Controller
{
    public function __construct(private GooglePlacesService $places) {}

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
            'session_token' => 'nullable|string|max:255',
            'type' => 'nullable|string|max:50',
        ]);

        $results = $this->places->autocomplete($data['query'], $data['session_token'] ?? null, $data['type'] ?? null);

        if ($results === null) {
            return response()->json(['data' => [], 'message' => 'Place search is not configured yet.']);
        }

        return response()->json(['data' => $results]);
    }

    public function show(Request $request, string $placeId): JsonResponse
    {
        $this->wedding($request);

        $data = $request->validate([
            'session_token' => 'nullable|string|max:255',
        ]);

        $place = $this->places->details($placeId, $data['session_token'] ?? null);

        if ($place === null) {
            return response()->json(['data' => null, 'message' => 'Place details are not available.']);
        }

        return response()->json(['data' => $place]);
    }
}
