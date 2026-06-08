<?php

namespace App\Http\Controllers\Api\Stripe;

use App\Http\Controllers\Controller;
use App\Models\CashFundContribution;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Stripe\Exception\SignatureVerificationException;
use Stripe\Webhook;

class StripeWebhookController extends Controller
{
    public function handle(Request $request): Response
    {
        $payload   = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature', '');
        $secret    = config('services.stripe.webhook_secret');

        try {
            $event = Webhook::constructEvent($payload, $sigHeader, $secret);
        } catch (SignatureVerificationException) {
            return response('Invalid signature', 400);
        }

        match ($event->type) {
            'checkout.session.completed' => $this->handleCheckoutCompleted($event->data->object),
            default                      => null,
        };

        return response('OK', 200);
    }

    private function handleCheckoutCompleted(object $session): void
    {
        $contribution = CashFundContribution::where('stripe_session_id', $session->id)->first();

        if (!$contribution || $contribution->status === 'paid') {
            return;
        }

        $contribution->update([
            'status'                   => 'paid',
            'stripe_payment_intent_id' => $session->payment_intent,
            'contributor_email'        => $session->customer_email,
        ]);

        $contribution->cashFund()->increment('raised_amount', $contribution->amount);
    }
}
