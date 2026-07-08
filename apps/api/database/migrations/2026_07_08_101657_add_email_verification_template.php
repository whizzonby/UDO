<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::table('email_templates')->insert([
            'key' => 'email_verification',
            'name' => 'Email verification',
            'subject' => 'Verify your email for Udo',
            'body' => <<<'HTML'
                <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">Verify your email</h2>
                <p style="margin:0 0 16px;">Hi {{first_name}}, please confirm this is your email address to finish setting up your Udo account.</p>
                <p style="margin:0 0 24px;text-align:center;">
                    <a href="{{verify_url}}" style="display:inline-block;background:#285301;color:#ffffff;text-decoration:none;padding:12px 28px;border-radius:10px;font-weight:600;">Verify email</a>
                </p>
                <p style="margin:0;color:#6b7280;font-size:13px;">This link will expire in 60 minutes. If you didn't create an account with Udo, you can safely ignore this email.</p>
                HTML,
            'available_variables' => json_encode(['first_name', 'verify_url']),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        DB::table('email_templates')->where('key', 'email_verification')->delete();
    }
};
