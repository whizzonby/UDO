<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        DB::table('email_templates')->insert([
            'key' => 'two_factor_code',
            'name' => 'Two-factor login code',
            'subject' => 'Your Udo login code: {{code}}',
            'body' => <<<'HTML'
                <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">Your login code</h2>
                <p style="margin:0 0 16px;">Hi {{first_name}}, use this code to finish signing in to Udo:</p>
                <p style="margin:0 0 24px;text-align:center;">
                    <span style="display:inline-block;background:#f4f1ea;color:#285301;letter-spacing:6px;font-size:28px;font-weight:700;padding:14px 28px;border-radius:10px;">{{code}}</span>
                </p>
                <p style="margin:0;color:#6b7280;font-size:13px;">This code expires in 10 minutes. If you didn't try to sign in, you can safely ignore this email.</p>
                HTML,
            'available_variables' => json_encode(['first_name', 'code']),
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function down(): void
    {
        DB::table('email_templates')->where('key', 'two_factor_code')->delete();
    }
};
