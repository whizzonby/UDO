<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\WeddingWeekendEvent;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WeddingWeekendController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function ensureCanManagePlan(Request $request): void
    {
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $this->wedding($request), 'manage_plan'), 403);
    }

    public function index(Request $request): JsonResponse
    {
        return response()->json(['data' => $this->wedding($request)->weddingWeekendEvents()->get()]);
    }

    private function rules(bool $partial = false): array
    {
        $req = $partial ? 'sometimes' : 'required';
        return [
            'title' => "$req|string|max:255",
            'event_date' => "$req|date",
            'start_time' => 'nullable|date_format:H:i',
            'end_time' => 'nullable|date_format:H:i',
            'location' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'audience' => 'nullable|in:all,wedding_party,family,travelling,vip,selected,private',
            'dress_code' => 'nullable|string|max:255',
            'host' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ];
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules());
        $event = $wedding->weddingWeekendEvents()->create($data);

        return response()->json(['data' => $event], 201);
    }

    public function update(Request $request, WeddingWeekendEvent $weddingWeekendEvent): JsonResponse
    {
        $this->authorizeEvent($request, $weddingWeekendEvent);
        $this->ensureCanManagePlan($request);

        $data = $request->validate($this->rules(partial: true));
        $weddingWeekendEvent->update($data);

        return response()->json(['data' => $weddingWeekendEvent->fresh()]);
    }

    public function destroy(Request $request, WeddingWeekendEvent $weddingWeekendEvent): JsonResponse
    {
        $this->authorizeEvent($request, $weddingWeekendEvent);
        $this->ensureCanManagePlan($request);
        $weddingWeekendEvent->delete();
        return response()->json(null, 204);
    }

    private function authorizeEvent(Request $request, WeddingWeekendEvent $weddingWeekendEvent): void
    {
        abort_unless($weddingWeekendEvent->wedding_id === $this->wedding($request)->id, 403);
    }
}
