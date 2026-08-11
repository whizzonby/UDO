<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class OpenAiService
{
    public function diagnostics(): array
    {
        $rawKey = config('services.openai.key');
        $key = $this->normalizedKey();
        $model = $this->model();

        return [
            'configured' => $key !== null,
            'model' => $model,
            'key_present' => is_string($rawKey) && trim($rawKey) !== '',
            'key_format_ok' => $key !== null && str_starts_with($key, 'sk-'),
            'key_length' => $key ? strlen($key) : 0,
            'key_fingerprint' => $key ? substr(hash('sha256', $key), 0, 12) : null,
        ];
    }

    /**
     * Sends a chat completion request to OpenAI with real wedding context
     * baked into the system prompt, plus recent conversation history, so
     * answers are grounded in this wedding's actual data rather than
     * generic filler. Throws on any failure — the caller must not save a
     * usage log (or count it against the monthly quota) for a failed call.
     */
    public function chat(string $systemPrompt, array $history, string $userMessage): string
    {
        $key = $this->normalizedKey();
        if ($key === null) {
            throw new RuntimeException('Udo AI is not configured yet.');
        }

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt],
            ...$history,
            ['role' => 'user', 'content' => $userMessage],
        ];

        $model = $this->model();

        try {
            $response = Http::withToken($key)
                ->acceptJson()
                ->asJson()
                ->connectTimeout(10)
                ->timeout(60)
                ->retry(2, 600)
                ->post('https://api.openai.com/v1/chat/completions', [
                    'model' => $model,
                    'messages' => $messages,
                    'temperature' => 0.6,
                    'max_tokens' => 700,
                ]);
        } catch (\Throwable $e) {
            Log::warning('OpenAI request failed', [
                'model' => $model,
                'error' => $e->getMessage(),
            ]);
            throw new RuntimeException("Couldn't reach Udo AI. Try again.");
        }

        if (! $response->successful()) {
            $status = $response->status();
            $providerMessage = $response->json('error.message') ?? $response->body();
            Log::warning('OpenAI returned an error', [
                'model' => $model,
                'status' => $status,
                'request_id' => $response->header('x-request-id'),
                'error' => $providerMessage,
            ]);

            if (in_array($status, [401, 403], true)) {
                throw new RuntimeException('Udo AI is not configured correctly. Please contact support.');
            }

            if ($status === 429) {
                throw new RuntimeException('Udo AI is temporarily at capacity. Please try again shortly.');
            }

            throw new RuntimeException("Couldn't reach Udo AI. Try again.");
        }

        $reply = $response->json('choices.0.message.content');
        if (! is_string($reply) || trim($reply) === '') {
            throw new RuntimeException("Udo AI didn't return a response. Try again.");
        }

        return trim($reply);
    }

    private function normalizedKey(): ?string
    {
        $key = config('services.openai.key');
        if (! is_string($key)) {
            return null;
        }

        $key = trim($key);
        $key = trim($key, "\"'<> \t\n\r\0\x0B");

        return $key !== '' ? $key : null;
    }

    private function model(): string
    {
        $model = config('services.openai.model', 'gpt-4o-mini');
        return is_string($model) && trim($model) !== '' ? trim($model) : 'gpt-4o-mini';
    }
}
