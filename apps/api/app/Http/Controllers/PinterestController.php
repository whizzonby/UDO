<?php

namespace App\Http\Controllers;

use App\Models\GalleryAsset;
use App\Models\Wedding;
use App\Services\WeddingAccessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

/**
 * A real OAuth 2.0 connection to Pinterest's public API (v5), gated behind
 * real configured credentials — when none are set, every endpoint here
 * degrades to an honest "not configured" response instead of pretending to
 * work. No Pinterest developer app exists for this project yet; the couple
 * (or whoever registers one) just needs to set the three PINTEREST_* env
 * vars and this starts working with no code changes.
 */
class PinterestController extends Controller
{
    private const AUTHORIZE_URL = 'https://www.pinterest.com/oauth/';
    private const TOKEN_URL = 'https://api.pinterest.com/v5/oauth/token';
    private const API_BASE = 'https://api.pinterest.com/v5';

    private function wedding(Request $request): Wedding
    {
        $wedding = $request->user()->activeWedding;
        abort_unless($wedding, 403, 'No active wedding.');
        abort_unless(app(WeddingAccessService::class)->canAccessWedding($request->user(), $wedding), 403);
        return $wedding;
    }

    private function isConfigured(): bool
    {
        return filled(config('services.pinterest.client_id'))
            && filled(config('services.pinterest.client_secret'))
            && filled(config('services.pinterest.redirect_uri'));
    }

    public function status(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        return response()->json(['data' => [
            'configured' => $this->isConfigured(),
            'connected' => filled($wedding->pinterest_access_token),
            'username' => $wedding->pinterest_username,
        ]]);
    }

    public function connect(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);

        if (! $this->isConfigured()) {
            return response()->json(['data' => ['configured' => false]]);
        }

        $state = Str::random(40);
        Cache::put("pinterest_oauth_state:{$state}", $wedding->id, now()->addMinutes(10));

        $query = http_build_query([
            'client_id' => config('services.pinterest.client_id'),
            'redirect_uri' => config('services.pinterest.redirect_uri'),
            'response_type' => 'code',
            'scope' => 'boards:read,pins:read',
            'state' => $state,
        ]);

        return response()->json(['data' => [
            'configured' => true,
            'authorize_url' => self::AUTHORIZE_URL . '?' . $query,
        ]]);
    }

    public function callback(Request $request): Response
    {
        $state = (string) $request->query('state');
        $code = $request->query('code');
        $weddingId = $state !== '' ? Cache::pull("pinterest_oauth_state:{$state}") : null;

        if (! $weddingId || ! $code) {
            return $this->htmlResponse('Connection failed', "We couldn't verify this Pinterest connection request. Please return to the app and try again.");
        }

        $wedding = Wedding::find($weddingId);
        if (! $wedding) {
            return $this->htmlResponse('Connection failed', 'This wedding could no longer be found.');
        }

        $tokenResponse = Http::asForm()->withBasicAuth(
            config('services.pinterest.client_id'),
            config('services.pinterest.client_secret'),
        )->post(self::TOKEN_URL, [
            'grant_type' => 'authorization_code',
            'code' => $code,
            'redirect_uri' => config('services.pinterest.redirect_uri'),
        ]);

        if ($tokenResponse->failed()) {
            return $this->htmlResponse('Connection failed', 'Pinterest did not accept this connection request. Please return to the app and try again.');
        }

        $tokenData = $tokenResponse->json();

        $accountResponse = Http::withToken($tokenData['access_token'] ?? '')->get(self::API_BASE . '/user_account');
        $username = $accountResponse->successful() ? $accountResponse->json('username') : null;

        $wedding->update([
            'pinterest_access_token' => $tokenData['access_token'] ?? null,
            'pinterest_refresh_token' => $tokenData['refresh_token'] ?? null,
            'pinterest_token_expires_at' => isset($tokenData['expires_in']) ? now()->addSeconds((int) $tokenData['expires_in']) : null,
            'pinterest_username' => $username,
        ]);

        return $this->htmlResponse('Pinterest connected', 'You can close this tab and return to the Udo app.');
    }

    public function boards(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($wedding->pinterest_access_token, 422, 'Pinterest is not connected.');

        $response = Http::withToken($wedding->pinterest_access_token)->get(self::API_BASE . '/boards');

        if ($response->failed()) {
            return response()->json(['message' => 'Could not load your Pinterest boards. Try reconnecting.'], 502);
        }

        $boards = collect($response->json('items', []))->map(fn ($board) => [
            'id' => $board['id'],
            'name' => $board['name'],
            'pin_count' => $board['pin_count'] ?? null,
            'image_url' => $board['media']['image_cover_url'] ?? null,
        ])->values();

        return response()->json(['data' => $boards]);
    }

    public function importBoard(Request $request, string $boardId): JsonResponse
    {
        $wedding = $this->wedding($request);
        abort_unless($wedding->pinterest_access_token, 422, 'Pinterest is not connected.');

        $response = Http::withToken($wedding->pinterest_access_token)->get(self::API_BASE . "/boards/{$boardId}/pins");

        if ($response->failed()) {
            return response()->json(['message' => 'Could not import this board. Try again.'], 502);
        }

        $imported = collect($response->json('items', []))->map(function ($pin) use ($wedding) {
            $imageUrl = $pin['media']['images']['originals']['url']
                ?? collect($pin['media']['images'] ?? [])->first()['url']
                ?? null;

            if (! $imageUrl) {
                return null;
            }

            return $wedding->galleryAssets()->create([
                'type' => 'photo',
                'source' => 'pinterest',
                'url' => $imageUrl,
                'thumbnail_url' => $imageUrl,
                'album' => 'inspiration',
                'caption' => $pin['title'] ?? $pin['description'] ?? null,
                'pinterest_source_url' => $pin['link'] ?? "https://www.pinterest.com/pin/{$pin['id']}/",
                'approved' => true,
            ]);
        })->filter()->values();

        return response()->json(['data' => $imported, 'imported' => $imported->count()]);
    }

    public function disconnect(Request $request): JsonResponse
    {
        $wedding = $this->wedding($request);
        $wedding->update([
            'pinterest_access_token' => null,
            'pinterest_refresh_token' => null,
            'pinterest_token_expires_at' => null,
            'pinterest_username' => null,
        ]);

        return response()->json(['data' => ['configured' => $this->isConfigured(), 'connected' => false, 'username' => null]]);
    }

    private function htmlResponse(string $title, string $body): Response
    {
        $html = <<<HTML
            <!doctype html>
            <html><head><meta charset="utf-8"><title>{$title}</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>body{font-family:system-ui,sans-serif;background:#F5F2EC;display:flex;align-items:center;justify-content:center;height:100vh;margin:0;text-align:center;}
            div{max-width:360px;padding:24px;}h1{color:#1F5B00;font-size:20px;}p{color:#555;font-size:14px;}</style>
            </head><body><div><h1>{$title}</h1><p>{$body}</p></div></body></html>
            HTML;

        return response($html, 200)->header('Content-Type', 'text/html');
    }
}
