<?php

namespace Tests\Feature;

use App\Mail\TemplatedMail;
use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class IapPurchaseTest extends TestCase
{
    use RefreshDatabase;

    public function test_verify_purchase_reports_not_configured_for_ios_without_credentials(): void
    {
        config(['services.apple_iap.shared_secret' => null, 'services.apple_iap.product_id' => null]);
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/verify-purchase', [
            'platform' => 'ios',
            'product_id' => 'udo_lifetime',
            'receipt_data' => 'base64-receipt-data',
        ])->assertOk()->assertJsonPath('data.configured', false);
    }

    public function test_verify_purchase_reports_not_configured_for_android_without_credentials(): void
    {
        config([
            'services.google_play.service_account_json' => null,
            'services.google_play.package_name' => null,
            'services.google_play.product_id' => null,
        ]);
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/verify-purchase', [
            'platform' => 'android',
            'product_id' => 'udo_lifetime',
            'purchase_token' => 'a-purchase-token',
        ])->assertOk()->assertJsonPath('data.configured', false);
    }

    public function test_valid_apple_receipt_grants_lifetime_and_sends_a_receipt_email_with_an_invoice(): void
    {
        config(['services.apple_iap.shared_secret' => 'shared-secret', 'services.apple_iap.product_id' => 'udo_lifetime']);
        Http::fake([
            'buy.itunes.apple.com/*' => Http::response([
                'status' => 0,
                'receipt' => [
                    'in_app' => [
                        ['product_id' => 'udo_lifetime', 'transaction_id' => '1000000123456789'],
                    ],
                ],
            ]),
        ]);
        Mail::fake();
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/verify-purchase', [
            'platform' => 'ios',
            'product_id' => 'udo_lifetime',
            'receipt_data' => 'base64-receipt-data',
        ])->assertOk()->assertJsonPath('data.configured', true);

        $subscription = $owner->fresh()->subscriptions()->latest()->first();
        $this->assertSame('lifetime', $subscription->plan);
        $this->assertSame('ios', $subscription->platform);
        $this->assertSame('1000000123456789', $subscription->platform_transaction_id);

        Mail::assertQueued(TemplatedMail::class, fn ($mail) => count($mail->attachments) === 1);
    }

    public function test_apple_receipt_for_the_wrong_product_is_rejected(): void
    {
        config(['services.apple_iap.shared_secret' => 'shared-secret', 'services.apple_iap.product_id' => 'udo_lifetime']);
        Http::fake([
            'buy.itunes.apple.com/*' => Http::response([
                'status' => 0,
                'receipt' => ['in_app' => [['product_id' => 'some_other_product', 'transaction_id' => '1']]],
            ]),
        ]);
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/verify-purchase', [
            'platform' => 'ios',
            'product_id' => 'udo_lifetime',
            'receipt_data' => 'base64-receipt-data',
        ])->assertStatus(422);

        $this->assertNull($owner->fresh()->subscriptions()->latest()->first());
    }

    public function test_valid_google_purchase_grants_lifetime_and_sends_a_receipt_email(): void
    {
        $serviceAccountPath = tempnam(sys_get_temp_dir(), 'gsa');
        file_put_contents($serviceAccountPath, json_encode([
            'client_email' => 'udo-iap@example.iam.gserviceaccount.com',
            'private_key' => $this->fakeRsaPrivateKey(),
        ]));

        config([
            'services.google_play.service_account_json' => $serviceAccountPath,
            'services.google_play.package_name' => 'com.udo.app',
            'services.google_play.product_id' => 'udo_lifetime',
        ]);

        Http::fake([
            'oauth2.googleapis.com/*' => Http::response(['access_token' => 'fake-access-token']),
            'androidpublisher.googleapis.com/*' => Http::response([
                'purchaseState' => 0,
                'orderId' => 'GPA.1234-5678-9012-34567',
            ]),
        ]);
        Mail::fake();
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->postJson('/api/billing/verify-purchase', [
            'platform' => 'android',
            'product_id' => 'udo_lifetime',
            'purchase_token' => 'a-purchase-token',
        ])->assertOk()->assertJsonPath('data.configured', true);

        $subscription = $owner->fresh()->subscriptions()->latest()->first();
        $this->assertSame('lifetime', $subscription->plan);
        $this->assertSame('android', $subscription->platform);
        $this->assertSame('GPA.1234-5678-9012-34567', $subscription->platform_transaction_id);

        Mail::assertQueued(TemplatedMail::class, fn ($mail) => count($mail->attachments) === 1);

        unlink($serviceAccountPath);
    }

    /**
     * A throwaway 2048-bit RSA test key (not used anywhere real) — generated
     * once ahead of time rather than via openssl_pkey_new() at test runtime,
     * since that call depends on an OS-level openssl.cnf being discoverable
     * and fails silently on some Windows PHP installs.
     */
    private function fakeRsaPrivateKey(): string
    {
        return <<<'PEM'
        -----BEGIN PRIVATE KEY-----
        MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCgK+UxShcBhi6h
        63yqsUjQnUJ4ZowcVdVF+1LiCkD2Du8+mQY9KjLjv8+Z0f+E1KXWVyhA53bPoTDN
        /1Fvjetl9At7ufHXTEhRIRTg2evwtQ/hZL/knLuMCsK6vrqMqa/dXwcFFtrWrsl2
        /WZox89l9KoTrpQOvufx/2zed+fuVvB1n6v0uufStbKHxD+FkaRvfAL7JgDod3XK
        TGMMDlmkNSvz/YgqR3meWKlfFZzroyOPfmYYaBUzTlFQDsPzZUb0HcWSx+c0jOkE
        GWlgF3mMItYnH5+/09CXqsMd7yjFHHFqFtY/pjuMtEt4dLkkbPc7xPVdCRqz5Hc3
        A/kCZsDZAgMBAAECggEADIaiRXjrB6sVgBz8aOG1NUTqUXDwY1IX4oGSRivrHJ/a
        XrJ05gxwyMk6IQHNOJDj6NLafdW1v7l2KZ+Rhmag31F276KBCTp/K7Xcl7qZh8xN
        66CHaTqtaBKtwkQilQshviKT8Y/x/6wEaviYk6uPyp3LPZkytvYZb+sIk1u1/zhQ
        DpXsHIpvuOwTxm7kL3RZlg27pJrkVejODg36Li/hfZCcM7XLd97ziG3LspXywERS
        yK/M7lwUGsAV9FPMEtluZvNdEFV2ky6GuwqmIC9O9pQ4vv+aeuZgFMdZ6hn33awZ
        5MJFMX1l9MDmR4djAbdqvbHl+UpXCGMfgbY0a/TsiQKBgQDNU0xKMOBOd16dcWXe
        PFjNZ0Hr9vtpkGnU5EIqfEbKXwrHdurWF6e4pp9gyVcydzvjJpHWcekZLz7sPT2J
        4nTMjOpW8W8z76hFmR7jMdAsMx1ZclMTTAHILRKYlqDP3bqm8yTaeC07jyAjQhSK
        EGGGvhmYcu/HVYI6BNYGCULkawKBgQDHs7gVsvvP6dhvpl59Li7HNUFWdHcvtYqQ
        O4gPtwRBDq0IEQDBQQkyTbXCwwP6dSs4U9syqCTVMZ/VOA1JKJSCS8fM/VOj1SGu
        RLp9pdNNdAjlvRK5M6mvTyaRHJmsIySYQKwTr9jZro5kK4sdD7pWwu1VH3gSwgjl
        JMmatvrgywKBgQCRBNRNUlgbE5Rv/zfDzzupV9TnpHnOBYG6K73P5BbbuGUUnJkg
        vXRopsbKxWog6rYRqZw3qhzI/OWkVVyxlpCIKL8ayUuRkyN2hL+cGALANRn1oxmp
        93UKvUr1Gu5Z4nGCmRjedSL9fglk3bdEDG3VjU7mrcdNMsfX0rKXcNMeIQKBgQCU
        ZNSmszBxKAhfttXB2V6DQuyBTNwABLupP8N0QgAUQ86KDvBrqmMmER6+UeGT7Bso
        qQ9aDh4Ime52J0egFFp+k8ctaRUMyeRUNdgKY/2nMVEnPh86pcwya/NxozoB8r9P
        r8bufh36a759aundt4E01XY8abz022B2vaZdpBi6jwKBgEicOkbhqgGY8CdyYo8y
        Dps0pQoQfDVmPEEoZeQaHWCa9wKQ5rXnEKkLeFjg+BmIzmA8ynPBIk7E6pzJP6WM
        dVdIIfyEjCVyJwqy6YW66yjyWr/H265qrY6LGj/ZBgVSNQhWsCdgydAXHVcSJWHf
        axy/8lfnFg1JE6npCp9b0cPH
        -----END PRIVATE KEY-----
        PEM;
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
