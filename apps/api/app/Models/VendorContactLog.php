<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class VendorContactLog extends Model
{
    protected $fillable = [
        'wedding_id',
        'vendor_id',
        'created_by',
        'contact_type',
        'subject',
        'body',
        'outcome',
        'contact_at',
        'follow_up_at',
    ];

    protected $casts = [
        'contact_at' => 'datetime',
        'follow_up_at' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function vendor(): BelongsTo { return $this->belongsTo(Vendor::class); }
    public function creator(): BelongsTo { return $this->belongsTo(User::class, 'created_by'); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }
}
