<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ChangePasswordTest extends TestCase
{
    use RefreshDatabase;

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = User::factory()->create(['password' => Hash::make('correct-password')]);
        Sanctum::actingAs($user);

        $this->postJson('/api/auth/change-password', [
            'current_password' => 'wrong-password',
            'password' => 'new-real-password',
            'password_confirmation' => 'new-real-password',
        ])->assertStatus(422)->assertJsonValidationErrors('current_password');

        $this->assertTrue(Hash::check('correct-password', $user->fresh()->password));
    }

    public function test_change_password_succeeds_with_correct_current_password(): void
    {
        $user = User::factory()->create(['password' => Hash::make('correct-password')]);
        Sanctum::actingAs($user);

        $this->postJson('/api/auth/change-password', [
            'current_password' => 'correct-password',
            'password' => 'new-real-password',
            'password_confirmation' => 'new-real-password',
        ])->assertOk();

        $this->assertTrue(Hash::check('new-real-password', $user->fresh()->password));
    }
}
