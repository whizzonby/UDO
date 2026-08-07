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
            throw new RuntimeException('The AI assistant is not configured yet.');
        }

        $messages = [
            ['role' => 'system', 'content' => $systemPrompt],
            ...$history,
            ['role' => 'user', 'content' => $userMessage],
        ];

        try {
            $response = Http::withToken($key)
                ->timeout(30)
                ->post('https://api.openai.com/v1/chat/completions', [
                    'model' => config('services.openai.model', 'gpt-4o-mini'),
                    'messages' => $messages,
                    'temperature' => 0.6,
                    'max_tokens' => 700,
                ]);
        } catch (\Throwable $e) {
            Log::warning('OpenAI request failed', ['error' => $e->getMessage()]);
            throw new RuntimeException("Couldn't reach the AI assistant. Try again.");
        }

        if (! $response->successful()) {
            Log::warning('OpenAI returned an error', [
                'status' => $response->status(),
                'body' => $response->json('error.message'),
            ]);
            throw new RuntimeException("Couldn't reach the AI assistant. Try again.");
        }

        $reply = $response->json('choices.0.message.content');
        if (! is_string($reply) || trim($reply) === '') {
            throw new RuntimeException("The AI assistant didn't return a response. Try again.");
        }

        return trim($reply);
    }
}
