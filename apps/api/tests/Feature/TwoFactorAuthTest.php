<?php

namespace Tests\Feature;

use App\Mail\TemplatedMail;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TwoFactorAuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_issues_a_challenge_instead_of_a_token_when_enabled(): void
    {
        $user = User::factory()->create([
            'password' => Hash::make('correct-password'),
            'two_factor_enabled' => true,
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'correct-password',
        ])->assertOk();

        $response->assertJson(['two_factor_required' => true]);
        $response->assertJsonMissing(['token' => null]);
        $this->assertArrayNotHasKey('token', $response->json());
        $this->assertNotEmpty($response->json('two_factor_token'));
        $this->assertNotEmpty($user->fresh()->two_factor_code);
    }

    public function test_verify_rejects_wrong_code_without_consuming_the_real_one(): void
    {
        $user = User::factory()->create([
            'password' => Hash::make('correct-password'),
            'two_factor_enabled' => true,
        ]);

        $login = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'correct-password',
        ])->assertOk();

        $token = $login->json('two_factor_token');

        $this->postJson('/api/auth/two-factor/verify', [
            'email' => $user->email,
            'two_factor_token' => $token,
            'code' => '000000',
        ])->assertStatus(422)->assertJsonValidationErrors('code');

        $this->assertSame(1, $user->fresh()->two_factor_attempts);
    }

    public function test_verify_succeeds_with_the_real_code_and_returns_a_working_token(): void
    {
        Mail::fake();

        $user = User::factory()->create([
            'password' => Hash::make('correct-password'),
            'two_factor_enabled' => true,
        ]);

        $login = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'correct-password',
        ])->assertOk();

        $token = $login->json('two_factor_token');

        $code = null;
        Mail::assertQueued(TemplatedMail::class, function (TemplatedMail $mail) use (&$code) {
            preg_match('/>(\d{6})<\/span>/', $mail->renderedBody, $matches);
            $code = $matches[1] ?? null;
            return true;
        });

        $this->assertNotNull($code, 'Could not find the emailed 2FA code in the rendered mail body.');

        $response = $this->postJson('/api/auth/two-factor/verify', [
            'email' => $user->email,
            'two_factor_token' => $token,
            'code' => $code,
        ])->assertOk();

        $this->assertNotEmpty($response->json('token'));
        $this->assertNull($user->fresh()->two_factor_challenge_token);

        $this->withHeader('Authorization', 'Bearer ' . $response->json('token'))
            ->getJson('/api/auth/me')
            ->assertOk();
    }

    public function test_five_wrong_attempts_locks_the_challenge(): void
    {
        $user = User::factory()->create([
            'password' => Hash::make('correct-password'),
            'two_factor_enabled' => true,
        ]);

        $login = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'correct-password',
        ])->assertOk();

        $token = $login->json('two_factor_token');

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/auth/two-factor/verify', [
                'email' => $user->email,
                'two_factor_token' => $token,
                'code' => '000000',
            ])->assertStatus(422);
        }

        $this->assertNull($user->fresh()->two_factor_challenge_token);
    }

    public function test_enable_rejects_wrong_password(): void
    {
        $user = User::factory()->create(['password' => Hash::make('correct-password')]);
        Sanctum::actingAs($user);

        $this->postJson('/api/auth/two-factor/enable', [
            'current_password' => 'wrong-password',
        ])->assertStatus(422)->assertJsonValidationErrors('current_password');

        $this->assertFalse($user->fresh()->two_factor_enabled);
    }

    public function test_enable_and_disable_succeed_with_correct_password(): void
    {
        $user = User::factory()->create(['password' => Hash::make('correct-password')]);
        Sanctum::actingAs($user);

        $this->postJson('/api/auth/two-factor/enable', [
            'current_password' => 'correct-password',
        ])->assertOk();
        $this->assertTrue($user->fresh()->two_factor_enabled);

        $this->postJson('/api/auth/two-factor/disable', [
            'current_password' => 'correct-password',
        ])->assertOk();
        $this->assertFalse($user->fresh()->two_factor_enabled);
    }
}
