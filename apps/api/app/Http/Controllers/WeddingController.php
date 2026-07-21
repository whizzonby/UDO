<?php

namespace App\Http\Controllers;

use App\Models\Wedding;
use App\Services\AuditLogService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class WeddingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $access = app(WeddingAccessService::class);
        $owned = $user->ownedWeddings()->get();
        $collaborating = $user->collaborations()->with('wedding')->get()->pluck('wedding')->filter();

        $weddings = $owned
            ->merge($collaborating)
            ->unique('id')
            ->values()
            ->map(function ($wedding) use ($user, $access) {
                $data = $wedding->toArray();
                $data['access'] = $access->payloadFor($user, $wedding);
                $data['is_active'] = $user->active_wedding_id === $wedding->id;

                return $data;
            });

        return response()->json(['data' => $weddings]);
    }

    public function show(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        return response()->json(array_merge(
            $wedding->toArray(),
            ['access' => app(WeddingAccessService::class)->payloadFor($request->user(), $wedding)]
        ));
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title'                 => 'nullable|string|max:255',
            'couple_name_primary'   => 'required|string|max:255',
            'couple_name_secondary' => 'nullable|string|max:255',
            'event_date'            => 'nullable|date',
            'city'                  => 'nullable|string|max:255',
            'country'               => 'nullable|string|max:255',
            'primary_venue_name'    => 'nullable|string|max:255',
            'primary_venue_address' => 'nullable|string',
            'rsvp_deadline'         => 'nullable|date',
            'settings'              => 'nullable|array',
        ]);

        $wedding = Wedding::create(array_merge($data, [
            'owner_user_id' => $request->user()->id,
            'status' => 'planning',
        ]));

        $request->user()->update([
            'active_wedding_id' => $wedding->id,
            'onboarding_completed' => true,
        ]);

        app(AuditLogService::class)->record('wedding.created', $wedding, $request->user()->fresh(), $wedding, null, [
            'id' => $wedding->id,
            'title' => $wedding->title,
            'couple_name_primary' => $wedding->couple_name_primary,
            'couple_name_secondary' => $wedding->couple_name_secondary,
            'event_date' => $wedding->event_date?->toDateString(),
        ], request: $request);

        return response()->json(array_merge(
            $wedding->toArray(),
            [
                'access' => app(WeddingAccessService::class)->payloadFor($request->user()->fresh(), $wedding),
                'is_active' => true,
            ]
        ), 201);
    }

    public function update(Request $request): JsonResponse
    {
        $wedding = $request->user()->activeWedding;

        abort_unless($wedding, 404, 'No wedding found.');
        abort_unless(app(WeddingAccessService::class)->can($request->user(), $wedding, 'manage_wedding'), 403);

        $data = $request->validate([
            'title'                 => 'nullable|string|max:255',
            'couple_name_primary'   => 'nullable|string|max:255',
            'couple_name_secondary' => 'nullable|string|max:255',
            'event_date'            => 'nullable|date',
            'city'                  => 'nullable|string|max:255',
            'country'               => 'nullable|string|max:255',
            'primary_venue_name'    => 'nullable|string|max:255',
            'primary_venue_address' => 'nullable|string',
            'rsvp_deadline'         => 'nullable|date',
            'settings'              => 'nullable|array',
        ]);

        $before = $wedding->only(array_keys($data));
        $wedding->update($data);

        $fresh = $wedding->fresh();
        [$beforeChanged, $afterChanged] = app(AuditLogService::class)->changes($before, $fresh->only(array_keys($data)), array_keys($data));

        if ($afterChanged) {
            app(AuditLogService::class)->record('wedding.updated', $fresh, $request->user(), $fresh, $beforeChanged, $afterChanged, request: $request);
        }

        return response()->json(array_merge(
            $fresh->toArray(),
            ['access' => app(WeddingAccessService::class)->payloadFor($request->user(), $fresh)]
        ));
    }

    public function switchActive(Request $request): JsonResponse
    {
        $data = $request->validate([
            'wedding_id' => ['required', 'integer', Rule::exists('weddings', 'id')],
        ]);

        $previousWeddingId = $request->user()->active_wedding_id;
        $wedding = Wedding::findOrFail($data['wedding_id']);
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);

        $request->user()->update(['active_wedding_id' => $wedding->id]);
        app(AuditLogService::class)->record('wedding.switched', $wedding, $request->user()->fresh(), $wedding, [
            'active_wedding_id' => $previousWeddingId,
        ], [
            'active_wedding_id' => $wedding->id,
        ], request: $request);

        return response()->json(array_merge(
            $wedding->toArray(),
            ['access' => app(WeddingAccessService::class)->payloadFor($request->user()->fresh(), $wedding)]
        ));
    }
}
