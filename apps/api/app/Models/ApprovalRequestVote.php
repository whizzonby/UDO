<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ApprovalRequestVote extends Model
{
    protected $fillable = [
        'approval_request_id', 'wedding_collaborator_id', 'decision', 'note',
    ];

    public function approvalRequest(): BelongsTo { return $this->belongsTo(ApprovalRequest::class); }
    public function collaborator(): BelongsTo { return $this->belongsTo(WeddingCollaborator::class, 'wedding_collaborator_id'); }
}
