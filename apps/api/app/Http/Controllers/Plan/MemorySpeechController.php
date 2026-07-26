<?php

namespace App\Http\Controllers\Plan;

use App\Http\Controllers\Controller;
use App\Models\MemorySpeech;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class MemorySpeechController extends Controller
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
        $wedding = $this->wedding($request);
        $isCoreCouple = app(WeddingAccessService::class)->isCoreCouple($request->user(), $wedding);

        $speeches = $wedding->memorySpeeches()
            ->when(! $isCoreCouple, fn ($q) => $q->where('visibility', 'shared'))
            ->get();

        return response()->json(['data' => $speeches]);
    }

    public function store(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'speaker_name' => 'required|string|max:255',
            'role' => 'nullable|string|max:100',
            'confirmed' => 'nullable|boolean',
            'duration_minutes' => 'nullable|integer|min:0',
            'speaking_order' => 'nullable|integer|min:0',
            'notes' => 'nullable|string',
            'visibility' => 'nullable|in:shared,private',
            'reminder_date' => 'nullable|date',
            'file' => 'nullable|file|mimes:pdf,doc,docx,txt|max:10240',
        ]);

        if ($request->hasFile('file')) {
            $data['draft_file_path'] = Storage::url($request->file('file')->store("weddings/{$wedding->id}/memories", 'public'));
        }
        unset($data['file']);

        $speech = $wedding->memorySpeeches()->create($data);

        return response()->json(['data' => $speech], 201);
    }

    public function update(Request $request, MemorySpeech $memorySpeech): JsonResponse
    {
        $this->authorizeSpeech($request, $memorySpeech);
        $this->ensureCanManagePlan($request);

        $data = $request->validate([
            'speaker_name' => 'sometimes|string|max:255',
            'role' => 'nullable|string|max:100',
            'confirmed' => 'nullable|boolean',
            'duration_minutes' => 'nullable|integer|min:0',
            'speaking_order' => 'nullable|integer|min:0',
            'notes' => 'nullable|string',
            'visibility' => 'nullable|in:shared,private',
            'reminder_date' => 'nullable|date',
            'file' => 'nullable|file|mimes:pdf,doc,docx,txt|max:10240',
        ]);

        if ($request->hasFile('file')) {
            $data['draft_file_path'] = Storage::url($request->file('file')->store("weddings/{$memorySpeech->wedding_id}/memories", 'public'));
        }
        unset($data['file']);

        $memorySpeech->update($data);

        return response()->json(['data' => $memorySpeech->fresh()]);
    }

    public function destroy(Request $request, MemorySpeech $memorySpeech): JsonResponse
    {
        $this->authorizeSpeech($request, $memorySpeech);
        $this->ensureCanManagePlan($request);
        $memorySpeech->delete();
        return response()->json(null, 204);
    }

    private function authorizeSpeech(Request $request, MemorySpeech $memorySpeech): void
    {
        abort_unless($memorySpeech->wedding_id === $this->wedding($request)->id, 403);
    }
}
