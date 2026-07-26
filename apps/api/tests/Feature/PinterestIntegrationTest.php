<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wedding;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PinterestIntegrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_connect_reports_not_configured_without_credentials(): void
    {
        config([
            'services.pinterest.client_id' => null,
            'services.pinterest.client_secret' => null,
            'services.pinterest.redirect_uri' => null,
        ]);
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->getJson('/api/pinterest/status')
            ->assertOk()
            ->assertJsonPath('data.configured', false)
            ->assertJsonPath('data.connected', false);

        $this->getJson('/api/pinterest/connect')
            ->assertOk()
            ->assertJsonPath('data.configured', false)
            ->assertJsonMissingPath('data.authorize_url');
    }

    public function test_connect_returns_a_real_authorize_url_with_valid_state_when_configured(): void
    {
        $this->configurePinterest();
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $response = $this->getJson('/api/pinterest/connect')
            ->assertOk()
            ->assertJsonPath('data.configured', true);

        $url = $response->json('data.authorize_url');
        $this->assertStringStartsWith('https://www.pinterest.com/oauth/', $url);
        $this->assertStringContainsString('client_id=test-client', $url);

        parse_str(parse_url($url, PHP_URL_QUERY), $query);
        $this->assertNotNull(Cache::get("pinterest_oauth_state:{$query['state']}"));
    }

    public function test_callback_exchanges_code_and_stores_token_and_username(): void
    {
        $this->configurePinterest();
        [$owner, $wedding] = $this->userWithWedding();
        $state = 'test-state-value';
        Cache::put("pinterest_oauth_state:{$state}", $wedding->id, now()->addMinutes(10));

        Http::fake([
            'api.pinterest.com/v5/oauth/token' => Http::response([
                'access_token' => 'real-access-token',
                'refresh_token' => 'real-refresh-token',
                'expires_in' => 3600,
            ], 200),
            'api.pinterest.com/v5/user_account' => Http::response(['username' => 'amara_and_theo'], 200),
        ]);

        $this->get("/api/pinterest/callback?code=abc123&state={$state}")
            ->assertOk()
            ->assertSee('Pinterest connected');

        $wedding->refresh();
        $this->assertSame('real-access-token', $wedding->pinterest_access_token);
        $this->assertSame('amara_and_theo', $wedding->pinterest_username);
        $this->assertNull(Cache::get("pinterest_oauth_state:{$state}"));
    }

    public function test_callback_with_invalid_state_shows_an_honest_failure_page_without_crashing(): void
    {
        $this->configurePinterest();

        $this->get('/api/pinterest/callback?code=abc123&state=not-a-real-state')
            ->assertOk()
            ->assertSee('Connection failed');
    }

    public function test_import_board_creates_real_gallery_assets_from_pins(): void
    {
        [$owner, $wedding] = $this->userWithWedding();
        $wedding->update(['pinterest_access_token' => 'real-token']);

        Http::fake([
            'api.pinterest.com/v5/boards/board-1/pins' => Http::response([
                'items' => [
                    [
                        'id' => 'pin-1',
                        'title' => 'Romantic florals',
                        'link' => 'https://pinterest.com/pin/pin-1/',
                        'media' => ['images' => ['originals' => ['url' => 'https://example.test/pin-1.jpg']]],
                    ],
                ],
            ], 200),
        ]);

        Sanctum::actingAs($owner);
        $this->postJson('/api/pinterest/boards/board-1/import')
            ->assertOk()
            ->assertJsonPath('imported', 1);

        $this->assertDatabaseHas('gallery_assets', [
            'wedding_id' => $wedding->id,
            'source' => 'pinterest',
            'album' => 'inspiration',
            'url' => 'https://example.test/pin-1.jpg',
            'pinterest_source_url' => 'https://pinterest.com/pin/pin-1/',
        ]);
    }

    public function test_boards_returns_honest_error_when_not_connected(): void
    {
        [$owner] = $this->userWithWedding();
        Sanctum::actingAs($owner);

        $this->getJson('/api/pinterest/boards')->assertStatus(422);
    }

    private function configurePinterest(): void
    {
        config([
            'services.pinterest.client_id' => 'test-client',
            'services.pinterest.client_secret' => 'test-secret',
            'services.pinterest.redirect_uri' => 'https://udowedding.com/api/pinterest/callback',
        ]);
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
