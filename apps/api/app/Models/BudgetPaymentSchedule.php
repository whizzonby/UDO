<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class BudgetPaymentSchedule extends Model
{
    protected $fillable = [
        'wedding_id',
        'budget_item_id',
        'vendor_id',
        'label',
        'amount',
        'due_date',
        'status',
        'payment_method',
        'reference',
        'receipt_path',
        'paid_at',
        'reminder_at',
        'notes',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'due_date' => 'date',
        'paid_at' => 'datetime',
        'reminder_at' => 'datetime',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function budgetItem(): BelongsTo { return $this->belongsTo(BudgetItem::class); }
    public function vendor(): BelongsTo { return $this->belongsTo(Vendor::class); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }
}
