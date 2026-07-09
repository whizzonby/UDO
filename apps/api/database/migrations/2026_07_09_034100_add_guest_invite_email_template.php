<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::table('email_templates')->insert([
            'key' => 'guest_invite',
            'name' => 'Guest invitation',
            'subject' => "You're invited to {{couple_names}}'s wedding!",
            'body' => <<<'HTML'
                <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">You're invited!</h2>
                <p style="margin:0 0 16px;">Hi {{first_name}}, {{couple_names}} would love for you to join them on {{event_date}}{{venue_line}}.</p>
                <p style="margin:0 0 24px;text-align:center;">
                    <a href="{{rsvp_url}}" style="display:inline-block;background:#285301;color:#ffffff;text-decoration:none;padding:12px 28px;border-radius:10px;font-weight:600;">View invitation &amp; RSVP</a>
                </p>
                <p style="margin:0;color:#6b7280;font-size:13px;">We can't wait to celebrate with you.</p>
                HTML,
            'available_variables' => json_encode(['first_name', 'couple_names', 'event_date', 'venue_line', 'rsvp_url']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        DB::table('email_templates')->where('key', 'guest_invite')->delete();
    }
};
