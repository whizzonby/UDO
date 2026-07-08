<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ThankYouRecord extends Model
{
    protected $fillable = [
        'wedding_id', 'guest_id', 'contribution_id', 'recipient_name',
        'recipient_email', 'reason', 'note', 'channel', 'status', 'sent_at',
    ];

    protected $casts = [
        'sent_at' => 'datetime',
    ];

    public function guest(): BelongsTo { return $this->belongsTo(Guest::class); }
    public function contribution(): BelongsTo { return $this->belongsTo(RegistryContribution::class, 'contribution_id'); }
}
