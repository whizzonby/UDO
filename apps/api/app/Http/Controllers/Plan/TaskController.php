<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        return $wedding;
    }

    public function index(Request $request): JsonResponse
    {
        $tasks = $this->wedding($request)
            ->tasks()
            ->orderBy('sort_order')
            ->orderBy('due_date')
            ->get();

        return response()->json(['data' => $tasks]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        $data = $request->validate([
            'title'       => 'required|string|max:255',
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

        $data = $request->validate([
            'title'        => 'sometimes|string|max:255',
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

        $task->update($data);

        return response()->json(['data' => $task->fresh()]);
    }

    public function destroy(Request $request, Task $task): JsonResponse
    {
        $this->authorizeTask($request, $task);
        $task->delete();
        return response()->json(null, 204);
    }

    private function authorizeTask(Request $request, Task $task): void
    {
        $wedding = $this->wedding($request);
        abort_unless($task->wedding_id === $wedding->id, 403);
    }
}
