<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TaskController extends Controller
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
        $tasks = $this->filteredTasks($request)
            ->orderBy('sort_order')
            ->orderBy('due_date')
            ->get();

        return response()->json(['data' => $tasks]);
    }

    public function export(Request $request)
    {
        $tasks = $this->filteredTasks($request)
            ->orderBy('sort_order')
            ->orderBy('due_date')
            ->get();

        $rows = $tasks->map(fn (Task $task) => [
            $task->title,
            $task->category,
            $task->priority,
            $task->completed ? 'completed' : 'pending',
            optional($task->due_date)->toDateString(),
            $task->vendor_id,
        ])->prepend(['title', 'category', 'priority', 'status', 'due_date', 'vendor_id']);

        return response($this->csv($rows), 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="tasks.csv"',
        ]);
    }

    private function filteredTasks(Request $request)
    {
        return $this->wedding($request)
            ->tasks()
            ->when($request->search, fn ($query) => $query->where(function ($search) use ($request) {
                $search->where('title', 'like', "%{$request->search}%")
                    ->orWhere('description', 'like', "%{$request->search}%")
                    ->orWhere('notes', 'like', "%{$request->search}%");
            }))
            ->when($request->category, fn ($query) => $query->where('category', $request->category))
            ->when($request->priority, fn ($query) => $query->where('priority', $request->priority))
            ->when($request->vendor_id, fn ($query) => $query->where('vendor_id', $request->vendor_id))
            ->when($request->status === 'completed', fn ($query) => $query->where('completed', true))
            ->when($request->status === 'pending', fn ($query) => $query->where('completed', false))
            ->when($request->status === 'overdue', fn ($query) => $query->where('completed', false)->whereDate('due_date', '<', now()->toDateString()))
            ->when($request->boolean('due_this_week'), fn ($query) => $query->where('completed', false)->whereBetween('due_date', [now()->toDateString(), now()->addWeek()->toDateString()]));
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title'       => 'required|string|max:255',
            'vendor_id'   => 'nullable|integer|exists:vendors,id',
            'description' => 'nullable|string',
            'category'    => 'nullable|string|max:100',
            'due_date'    => 'nullable|date',
            'priority'    => 'nullable|in:low,medium,high,urgent',
            'assigned_to' => 'nullable|integer|exists:users,id',
            'notes'       => 'nullable|string',
            'sort_order'  => 'nullable|integer',
        ]);

        $task = $wedding->tasks()->create([
            ...$data,
            'vendor_id' => $this->authorizedVendorId($request, $data['vendor_id'] ?? null),
            'created_by' => $request->user()->id,
        ]);

        return response()->json(['data' => $task], 201);
    }

    public function show(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTask($request, $task);
        return response()->json(['data' => $task->load('assignee')]);
    }

    public function update(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTask($request, $task);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'title'        => 'sometimes|string|max:255',
            'vendor_id'    => 'nullable|integer|exists:vendors,id',
            'description'  => 'nullable|string',
            'category'     => 'nullable|string|max:100',
            'due_date'     => 'nullable|date',
            'priority'     => 'nullable|in:low,medium,high,urgent',
            'completed'    => 'nullable|boolean',
            'assigned_to'  => 'nullable|integer|exists:users,id',
            'notes'        => 'nullable|string',
            'sort_order'   => 'nullable|integer',
        ]);

        if (isset($data['completed']) && $data['completed'] && !$task->completed) {
            $data['completed_at'] = now();
        } elseif (isset($data['completed']) && !$data['completed']) {
            $data['completed_at'] = null;
        }

        if (array_key_exists('vendor_id', $data)) {
            $data['vendor_id'] = $this->authorizedVendorId($request, $data['vendor_id']);
        }

        $task->update($data);

        return response()->json(['data' => $task->fresh()]);
    }

    public function destroy(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTask($request, $task);
        $this->ensureCanManagePlan($request);
        $task->delete();
        return response()->json(null, 204);
    }

    public function bulkUpdate(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'ids' => 'required|array|min:1',
            'ids.*' => 'integer',
            'updates' => 'required|array',
            'updates.completed' => 'nullable|boolean',
            'updates.priority' => 'nullable|in:low,medium,high,urgent',
            'updates.category' => 'nullable|string|max:100',
            'updates.vendor_id' => 'nullable|integer|exists:vendors,id',
            'updates.assigned_to' => 'nullable|integer|exists:users,id',
            'confirm' => 'accepted',
        ]);

        $updates = collect($data['updates'])->only(['completed', 'priority', 'category', 'vendor_id', 'assigned_to'])->all();
        abort_if(empty($updates), 422, 'No supported updates were provided.');
        if (array_key_exists('vendor_id', $updates)) {
            $updates['vendor_id'] = $this->authorizedVendorId($request, $updates['vendor_id']);
        }
        if (array_key_exists('completed', $updates)) {
            $updates['completed_at'] = $updates['completed'] ? now() : null;
        }

        $tasks = $wedding->tasks()->whereIn('id', $data['ids'])->get();
        abort_unless($tasks->count() === count(array_unique($data['ids'])), 422, 'One or more tasks do not belong to this wedding.');

        $wedding->tasks()->whereIn('id', $data['ids'])->update($updates);

        return response()->json([
            'updated' => $tasks->count(),
            'data' => $wedding->tasks()->whereIn('id', $data['ids'])->orderBy('due_date')->get(),
        ]);
    }

    private function authorizeTask(Request $request, Task $task): void
    {
        $wedding = $this->wedding($request);
        abort_unless($task->wedding_id === $wedding->id, 403);
    }

    private function authorizedVendorId(Request $request, ?int $vendorId): ?int
    {
        if (!$vendorId) {
            return null;
        }

        abort_unless($this->wedding($request)->vendors()->whereKey($vendorId)->exists(), 422, 'Vendor does not belong to this wedding.');

        return $vendorId;
    }

    private function csv($rows): string
    {
        return $rows->map(fn ($row) => collect($row)->map(fn ($value) => '"' . str_replace('"', '""', (string) $value) . '"')->implode(','))->implode("\n") . "\n";
    }
}
