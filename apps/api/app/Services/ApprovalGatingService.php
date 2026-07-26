<?php

namespace App\Services;

use App\Models\ApprovalRequest;
use App\Models\User;
use App\Models\Wedding;
use App\Models\WeddingCollaborator;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Collection;
use InvalidArgumentException;

class ApprovalGatingService
{
    /**
     * Real decision-makers for this category, excluding whoever is making
     * the change — gating only activates when someone else actually needs
     * to sign off, so weddings without Decision Makers set up (or where the
     * requester is the only one) see no behaviour change at all.
     */
    public function requiredApprovers(Wedding $wedding, string $category, User $requester): Collection
    {
        return $wedding->collaborators()
            ->where('is_decision_maker', true)
            ->whereNotNull('accepted_at')
            ->where('user_id', '!=', $requester->id)
            ->get()
            ->filter(fn (WeddingCollaborator $collaborator) => in_array($category, $collaborator->approval_categories ?? [], true))
            ->values();
    }

    /**
     * Applies $payload immediately if no one else needs to approve it,
     * otherwise creates a real pending ApprovalRequest and leaves $subject
     * untouched until every required approver has voted to approve.
     */
    public function requestOrApply(
        Wedding $wedding,
        string $category,
        Model $subject,
        array $payload,
        User $requester,
        string $title,
        ?string $description = null,
    ): array {
        $approvers = $this->requiredApprovers($wedding, $category, $requester);

        if ($approvers->isEmpty()) {
            $subject->update($payload);
            return ['gated' => false, 'subject' => $subject->fresh()];
        }

        $request = ApprovalRequest::create([
            'wedding_id' => $wedding->id,
            'category' => $category,
            'subject_type' => get_class($subject),
            'subject_id' => $subject->getKey(),
            'action' => $payload === [] ? 'update' : implode(',', array_keys($payload)),
            'title' => $title,
            'description' => $description,
            'requested_by' => $requester->id,
            'payload' => $payload,
            'status' => 'pending',
        ]);

        return ['gated' => true, 'request' => $request];
    }

    public function vote(ApprovalRequest $request, WeddingCollaborator $voter, string $decision, ?string $note = null): ApprovalRequest
    {
        if ($request->status !== 'pending') {
            throw new InvalidArgumentException('This request has already been resolved.');
        }

        $request->votes()->updateOrCreate(
            ['wedding_collaborator_id' => $voter->id],
            ['decision' => $decision, 'note' => $note],
        );

        if ($decision === 'reject') {
            $request->update(['status' => 'rejected', 'resolved_at' => now()]);
            return $request->fresh('votes');
        }

        $requester = $request->requester;
        $requiredApprovers = $this->requiredApprovers($request->wedding, $request->category, $requester);
        $approvedCollaboratorIds = $request->votes()->where('decision', 'approve')->pluck('wedding_collaborator_id');

        $allApproved = $requiredApprovers->isNotEmpty()
            && $requiredApprovers->every(fn (WeddingCollaborator $approver) => $approvedCollaboratorIds->contains($approver->id));

        if ($allApproved) {
            $subject = $request->subject;
            $subject?->update($request->payload);
            $request->update(['status' => 'approved', 'resolved_at' => now()]);
        }

        return $request->fresh('votes');
    }
}
