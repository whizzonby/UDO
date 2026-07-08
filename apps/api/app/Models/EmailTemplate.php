<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmailTemplate extends Model
{
    protected $fillable = ['key', 'name', 'subject', 'body', 'available_variables'];

    protected $casts = [
        'available_variables' => 'array',
    ];

    /**
     * Render a template's subject + body, substituting {{variable}} placeholders.
     * Every value is HTML-escaped, including inside the body, since variables
     * (names, links) may originate from user input.
     */
    public static function render(string $key, array $data = []): array
    {
        $template = static::where('key', $key)->firstOrFail();

        $substitute = fn (string $text) => preg_replace_callback(
            '/\{\{\s*(\w+)\s*\}\}/',
            fn (array $match) => e($data[$match[1]] ?? ''),
            $text
        );

        return [
            'subject' => $substitute($template->subject),
            'body' => $substitute($template->body),
        ];
    }
}
