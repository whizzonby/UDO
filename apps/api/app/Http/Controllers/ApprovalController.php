<?php

namespace App\Http\Controllers;

use App\Models\ApprovalRequest;
use App\Models\WeddingCollaborator;
use App\Services\ApprovalGatingService;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

class ApprovalController extends Controller
{
    private function wedding(Request $request)
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    public function index(Request $request, ApprovalGatingService $gating): JsonResponse
    {
        $wedding = $this->wedding($request);
        $requests = $wedding->approvalRequests()->with(['votes.collaborator.user', 'requester'])->get();

        return response()->json([
            'data' => $requests->map(fn (ApprovalRequest $ar) => $this->payload($ar, $gating))->values(),
        ]);
    }

    public function vote(Request $request, ApprovalRequest $approvalRequest, ApprovalGatingService $gating): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($approvalRequest->wedding_id === $wedding->id, 403);

        $data = $request->validate([
            'decision' => 'required|in:approve,reject',
            'note' => 'nullable|string',
        ]);

        $voter = WeddingCollaborator::where('wedding_id', $wedding->id)
            ->where('user_id', $request->user()->id)
            ->first();
        abort_unless($voter, 403, 'You are not a collaborator on this wedding.');

        $requiredApprovers = $gating->requiredApprovers($wedding, $approvalRequest->category, $approvalRequest->requester);
        abort_unless($requiredApprovers->contains('id', $voter->id), 403, 'You are not a required approver for this request.');

        try {
            $updated = $gating->vote($approvalRequest, $voter, $data['decision'], $data['note'] ?? null);
        } catch (InvalidArgumentException $e) {
            abort(422, $e->getMessage());
        }

        return response()->json(['data' => $this->payload($updated->load(['votes.collaborator.user', 'requester']), $gating)]);
    }

    private function payload(ApprovalRequest $ar, ApprovalGatingService $gating): array
    {
        $requiredApprovers = $gating->requiredApprovers($ar->wedding, $ar->category, $ar->requester);

        return [
            'id' => $ar->id,
            'category' => $ar->category,
            'action' => $ar->action,
            'title' => $ar->title,
            'description' => $ar->description,
            'status' => $ar->status,
            'requested_by' => $ar->requester?->name,
            'created_at' => $ar->created_at?->toISOString(),
            'resolved_at' => optional($ar->resolved_at)->toISOString(),
            'required_approvers' => $requiredApprovers->map(fn (WeddingCollaborator $c) => [
                'id' => $c->id,
                'name' => $c->user?->name,
            ])->values(),
            'votes' => $ar->votes->map(fn ($vote) => [
                'collaborator_id' => $vote->wedding_collaborator_id,
                'name' => $vote->collaborator?->user?->name,
                'decision' => $vote->decision,
                'note' => $vote->note,
            ])->values(),
        ];
    }
}
