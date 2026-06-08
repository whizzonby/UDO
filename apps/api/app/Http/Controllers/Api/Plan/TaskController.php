<?php

namespace App\Http\Controllers\Api\Plan;

use App\Http\Controllers\Controller;
use App\Http\Requests\Plan\StoreTaskRequest;
use App\Http\Requests\Plan\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TaskController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $wedding = $request->user()->weddings()->firstOrFail();
        $tasks   = $wedding->tasks()->orderBy('sort_order')->get();

        return TaskResource::collection($tasks);
    }

    public function store(StoreTaskRequest $request): JsonResponse
    {
        $wedding = $request->user()->weddings()->firstOrFail();

        $task = $wedding->tasks()->create([
            ...$request->validated(),
            'created_by' => $request->user()->id,
            'sort_order' => $wedding->tasks()->max('sort_order') + 1,
        ]);

        return response()->json(new TaskResource($task), 201);
    }

    public function update(UpdateTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorizeWedding($request, $task->wedding_id);

        $data = $request->validated();

        if (isset($data['status']) && $data['status'] === 'complete' && $task->status !== 'complete') {
            $data['completed_at'] = now();
        } elseif (isset($data['status']) && $data['status'] !== 'complete') {
            $data['completed_at'] = null;
        }

        $task->update($data);

        return response()->json(new TaskResource($task->fresh()));
    }

    public function destroy(Request $request, Task $task): JsonResponse
    {
        $this->authorizeWedding($request, $task->wedding_id);
        $task->delete();

        return response()->json(['message' => 'Task deleted.']);
    }

    private function authorizeWedding(Request $request, string $weddingId): void
    {
        abort_unless(
            $request->user()->weddings()->where('weddings.id', $weddingId)->exists(),
            403,
            'Forbidden.'
        );
    }
}
