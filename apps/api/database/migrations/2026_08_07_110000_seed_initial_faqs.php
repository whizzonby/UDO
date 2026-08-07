<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        DB::table('faqs')->insert([
            [
                'question' => 'How do I RSVP?',
                'answer' => "Use the personal invitation link sent to your email, SMS, or WhatsApp — it's tied to your name, so your RSVP, meal choice, and plus-one details attach correctly. This public wedding page doesn't collect RSVPs directly.",
                'category' => 'planning',
                'sort_order' => 1,
                'is_visible' => true,
                'featured' => false,
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'question' => "I can't find my invitation link. What do I do?",
                'answer' => 'Use the "Message Us" button on this page and let the couple know — they can resend it to you.',
                'category' => 'planning',
                'sort_order' => 2,
                'is_visible' => true,
                'featured' => false,
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'question' => 'Can I bring a plus-one?',
                'answer' => "This depends on your individual invitation — check your personal invitation link, which will show whether a plus-one option is available to you.",
                'category' => 'planning',
                'sort_order' => 3,
                'is_visible' => true,
                'featured' => false,
                'created_at' => $now,
                'updated_at' => $now,
            ],
        ]);
    }

    public function down(): void
    {
        DB::table('faqs')->whereIn('question', [
            'How do I RSVP?',
            "I can't find my invitation link. What do I do?",
            'Can I bring a plus-one?',
        ])->delete();
    }
};
