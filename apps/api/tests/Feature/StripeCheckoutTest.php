<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StripeCheckoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_checkout_session_reports_not_configured_without_credentials(): void
    {
        config(['services.stripe.secret_key' => null]);
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/checkout-session')
            ->assertOk()
            ->assertJsonPath('data.configured', false)
            ->assertJsonMissingPath('data.checkout_url');
    }

    public function test_webhook_rejects_an_incorrectly_signed_payload(): void
    {
        config([
            'services.stripe.secret_key' => 'sk_test_fake',
            'services.stripe.webhook_secret' => 'whsec_test_fake',
        ]);

        $this->postJson('/api/webhooks/stripe', ['type' => 'checkout.session.completed'], [
            'Stripe-Signature' => 't=' . time() . ',v1=not-a-real-signature',
        ])->assertStatus(400);
    }

    public function test_webhook_grants_lifetime_plan_on_a_correctly_signed_checkout_completed_event(): void
    {
        $webhookSecret = 'whsec_test_fake';
        config([
            'services.stripe.secret_key' => 'sk_test_fake',
            'services.stripe.webhook_secret' => $webhookSecret,
        ]);
        [$owner, $wedding] = $this->userWithWedding();

        $payload = json_encode([
            'id' => 'evt_test123',
            'type' => 'checkout.session.completed',
            'data' => [
                'object' => [
                    'id' => 'cs_test_123',
                    'object' => 'checkout.session',
                    'client_reference_id' => (string) $owner->id,
                    'payment_status' => 'paid',
                    'amount_total' => 4500,
                    'currency' => 'usd',
                ],
            ],
        ]);

        $timestamp = time();
        $signedPayload = "{$timestamp}.{$payload}";
        $signature = hash_hmac('sha256', $signedPayload, $webhookSecret);

        $this->call('POST', '/api/webhooks/stripe', [], [], [], [
            'HTTP_STRIPE-SIGNATURE' => "t={$timestamp},v1={$signature}",
            'CONTENT_TYPE' => 'application/json',
        ], $payload)->assertOk();

        $subscription = $owner->fresh()->subscriptions()->latest()->first();
        $this->assertNotNull($subscription);
        $this->assertSame('lifetime', $subscription->plan);
        $this->assertSame('active', $subscription->status);
        $this->assertSame(45.0, (float) $subscription->amount);
        $this->assertSame('cs_test_123', $subscription->stripe_checkout_session_id);
    }

    public function test_lifetime_plan_cannot_be_self_selected_via_change_plan(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/plan', ['plan' => 'lifetime', 'confirm' => true])
            ->assertStatus(422);
    }

    private function userWithWedding(): array
    {
        $user = User::factory()->create();
        $wedding = Wedding::create([
            'couple_name_primary' => 'Amara',
            'couple_name_secondary' => 'Theo',
            'owner_user_id' => $user->id,
        ]);
        $user->update(['active_wedding_id' => $wedding->id]);

        return [$user->fresh(), $wedding];
    }
}
