<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class OpenAiService
{
    /**
     * Sends a chat completion request to OpenAI with real wedding context
     * baked into the system prompt, plus recent conversation history, so
     * answers are grounded in this wedding's actual data rather than
     * generic filler. Throws on any failure — the caller must not save a
     * usage log (or count it against the monthly quota) for a failed call.
     */
    public function chat(string $systemPrompt, array $history, string $userMessage): string
    {
        $key = config('services.openai.key');
        if (empty($key)) {
            throw new RuntimeException('Udo AI is not configured yet.');
        }

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt],
            ...$history,
            ['role' => 'user', 'content' => $userMessage],
        ];

        $model = config('services.openai.model', 'gpt-4o-mini');

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
            Log::warning('OpenAI returned an error', [
                'model' => $model,
                'status' => $response->status(),
                'request_id' => $response->header('x-request-id'),
                'error' => $response->json('error.message') ?? $response->body(),
            ]);
            throw new RuntimeException("Couldn't reach Udo AI. Try again.");
        }

        $reply = $response->json('choices.0.message.content');
        if (! is_string($reply) || trim($reply) === '') {
            throw new RuntimeException("Udo AI didn't return a response. Try again.");
        }

        return trim($reply);
    }
}
