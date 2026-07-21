<?php

namespace App\Http\Middleware;

use App\Models\IdempotencyKey;
use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IdempotencyMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! in_array($request->method(), ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
            return $next($request);
        }

        $key = trim((string) $request->header('Idempotency-Key'));
        if ($key === '') {
            return $next($request);
        }

        abort_if(strlen($key) > 120, 422, 'Idempotency-Key must be 120 characters or fewer.');

        $userId = $request->user()?->id;
        $method = $request->method();
        $path = '/' . ltrim($request->path(), '/');
        $requestHash = hash('sha256', $method . '|' . $path . '|' . $request->getContent());

        $existing = IdempotencyKey::query()
            ->where('user_id', $userId)
            ->where('key', $key)
            ->where('method', $method)
            ->where('path', $path)
            ->where('expires_at', '>', now())
            ->first();

        if ($existing) {
            if (! hash_equals($existing->request_hash, $requestHash)) {
                return response()->json([
                    'message' => 'This Idempotency-Key was already used with a different request body.',
                ], 409);
            }

            return response()->json($existing->response_body ?? [], $existing->status_code, [
                'Idempotency-Replayed' => 'true',
            ]);
        }

        $response = $next($request);

        if ($response instanceof JsonResponse && $response->getStatusCode() < 500) {
            IdempotencyKey::query()->updateOrCreate(
                [
                    'user_id' => $userId,
                    'key' => $key,
                    'method' => $method,
                    'path' => $path,
                ],
                [
                    'request_hash' => $requestHash,
                    'status_code' => $response->getStatusCode(),
                    'response_body' => json_decode($response->getContent(), true),
                    'expires_at' => now()->addHours(24),
                ],
            );
        }

        return $response;
    }
}
