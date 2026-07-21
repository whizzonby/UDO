<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;

class Vendor extends Model
{
    protected $fillable = [
        'wedding_id', 'name', 'contact_person', 'category', 'email', 'phone',
        'website', 'instagram', 'quoted_price', 'deposit_paid', 'balance_due',
        'deposit_due_date', 'balance_due_date', 'booking_status',
        'contract_signed', 'contract_file_url', 'on_timeline', 'priority', 'notes',
    ];

    protected $casts = [
        'quoted_price' => 'decimal:2',
        'deposit_paid' => 'decimal:2',
        'balance_due' => 'decimal:2',
        'deposit_due_date' => 'date',
        'balance_due_date' => 'date',
        'contract_signed' => 'boolean',
        'on_timeline' => 'boolean',
    ];

    public function wedding(): BelongsTo { return $this->belongsTo(Wedding::class); }
    public function budgetItems(): HasMany { return $this->hasMany(BudgetItem::class); }
    public function contactLogs(): HasMany { return $this->hasMany(VendorContactLog::class)->latest('contact_at')->latest(); }
    public function tasks(): HasMany { return $this->hasMany(Task::class); }
    public function subjectAuditLogs(): MorphMany { return $this->morphMany(AuditLog::class, 'auditable'); }
}
