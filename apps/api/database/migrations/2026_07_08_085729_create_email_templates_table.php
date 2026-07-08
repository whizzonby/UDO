<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('email_templates', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->string('name');
            $table->string('subject');
            $table->longText('body');
            $table->json('available_variables')->nullable();
            $table->timestamps();
        });

        $now = now();

        DB::table('email_templates')->insert([
            [
                'key' => 'welcome',
                'name' => 'Welcome email',
                'subject' => 'Welcome to Udo, {{first_name}}!',
                'body' => <<<'HTML'
                    <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">Welcome to Udo, {{first_name}}!</h2>
                    <p style="margin:0 0 16px;">We're so glad you're here. Udo brings your whole wedding — planning, guests, the big day itself — into one calm, organised place.</p>
                    <p style="margin:0 0 16px;">A few things you can do right away:</p>
                    <ul style="margin:0 0 16px;padding-left:20px;">
                        <li>Finish setting up your wedding details</li>
                        <li>Invite your partner or planner to collaborate</li>
                        <li>Start building your guest list</li>
                    </ul>
                    <p style="margin:0;">We can't wait to help you plan something beautiful.</p>
                    HTML,
                'available_variables' => json_encode(['first_name', 'last_name']),
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'key' => 'password_reset',
                'name' => 'Password reset',
                'subject' => 'Reset your Udo password',
                'body' => <<<'HTML'
                    <h2 style="margin:0 0 16px;color:#285301;font-family:Georgia,serif;">Reset your password</h2>
                    <p style="margin:0 0 16px;">Hi {{first_name}}, we received a request to reset the password for your Udo account. Click below to choose a new one.</p>
                    <p style="margin:0 0 24px;text-align:center;">
                        <a href="{{reset_url}}" style="display:inline-block;background:#285301;color:#ffffff;text-decoration:none;padding:12px 28px;border-radius:10px;font-weight:600;">Reset password</a>
                    </p>
                    <p style="margin:0 0 8px;color:#6b7280;font-size:13px;">This link will expire in 60 minutes. If you didn't request a password reset, you can safely ignore this email.</p>
                    HTML,
                'available_variables' => json_encode(['first_name', 'reset_url']),
                'created_at' => $now,
                'updated_at' => $now,
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('email_templates');
    }
};
