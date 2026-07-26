<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Reminder;
use App\Services\ReminderService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReminderController extends Controller
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
        $reminders = $this->wedding($request)->reminders()->get();
        return response()->json(['data' => $reminders]);
    }

    public function refresh(Request $request, ReminderService $reminders): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $reminders->refresh($wedding);

        return response()->json(['data' => $wedding->reminders()->get()]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'nullable|in:low,medium,high',
        ]);

        $reminder = $wedding->reminders()->create([...$data, 'source' => 'manual']);

        return response()->json(['data' => $reminder], 201);
    }

    public function update(Request $request, Reminder $reminder): JsonResponse
    {
        $this->authorizeReminder($request, $reminder);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'priority' => 'nullable|in:low,medium,high',
            'status' => 'nullable|in:pending,completed',
        ]);

        $reminder->update($data);

        return response()->json(['data' => $reminder->fresh()]);
    }

    public function destroy(Request $request, Reminder $reminder): JsonResponse
    {
        $this->authorizeReminder($request, $reminder);
        $this->ensureCanManagePlan($request);
        $reminder->delete();
        return response()->json(null, 204);
    }

    private function authorizeReminder(Request $request, Reminder $reminder): void
    {
        abort_unless($reminder->wedding_id === $this->wedding($request)->id, 403);
    }
}
