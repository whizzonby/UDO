<?php

namespace App\Services;

use App\Models\Subscription;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Storage;

/**
 * Renders a real one-page PDF invoice for a completed subscription purchase,
 * from the subscription's own real amount/date/platform — no fabricated
 * line items or made-up invoice history.
 */
class InvoiceService
{
    /**
     * Persists the invoice to storage and returns its disk path, rather
     * than the raw PDF bytes — attaching a mailable to an in-memory binary
     * blob breaks queue serialization (the queue payload is JSON-encoded,
     * and raw PDF bytes aren't valid UTF-8), so every consumer attaches by
     * path via Storage::path() instead.
     */
    public function generate(Subscription $subscription): string
    {
        $subscription->loadMissing('user');

        $pdf = Pdf::loadView('invoices.purchase', [
            'invoiceNumber' => str_pad((string) $subscription->id, 6, '0', STR_PAD_LEFT),
            'customerName' => $subscription->user->full_name,
            'customerEmail' => $subscription->user->email,
            'date' => $subscription->current_period_start?->format('M j, Y') ?? now()->format('M j, Y'),
            'platformLabel' => match ($subscription->platform) {
                'ios' => 'Apple In-App Purchase',
                'android' => 'Google Play Billing',
                default => 'Card (Stripe)',
            },
            'planLabel' => SubscriptionEntitlementService::PLANS[$subscription->plan]['label'] ?? $subscription->plan,
            'amount' => number_format((float) $subscription->amount, 2),
        ])->output();

        $path = "invoices/udo-invoice-{$subscription->id}.pdf";
        Storage::disk('local')->put($path, $pdf);

        return $path;
    }
}
