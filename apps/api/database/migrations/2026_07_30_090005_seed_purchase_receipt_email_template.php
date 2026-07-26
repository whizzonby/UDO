<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        DB::table('email_templates')->insert([
            'key' => 'purchase_receipt',
            'name' => 'Purchase receipt',
            'subject' => 'Your Udo receipt — {{plan_label}}',
            'body' => <<<'HTML'
                <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">Thanks, {{first_name}}!</h2>
                <p style="margin:0 0 16px;">Your payment for Udo has gone through. Here are the details for your records — the full invoice is attached as a PDF.</p>
                <table style="margin:0 0 16px;width:100%;border-collapse:collapse;">
                    <tr><td style="padding:6px 0;color:#6b7280;">Plan</td><td style="padding:6px 0;text-align:right;">{{plan_label}}</td></tr>
                    <tr><td style="padding:6px 0;color:#6b7280;">Amount</td><td style="padding:6px 0;text-align:right;">{{amount}}</td></tr>
                    <tr><td style="padding:6px 0;color:#6b7280;">Date</td><td style="padding:6px 0;text-align:right;">{{date}}</td></tr>
                </table>
                <p style="margin:0;">Welcome to lifetime access — no subscriptions, ever.</p>
                HTML,
            'available_variables' => json_encode(['first_name', 'plan_label', 'amount', 'date']),
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function down(): void
    {
        DB::table('email_templates')->where('key', 'purchase_receipt')->delete();
    }
};
