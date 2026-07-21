<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->boolean('email_opt_out')->default(false)->after('email');
            $table->boolean('sms_opt_out')->default(false)->after('phone');
            $table->boolean('whatsapp_opt_out')->default(false)->after('sms_opt_out');
            $table->timestamp('communication_preferences_updated_at')->nullable()->after('whatsapp_opt_out');
        });
    }

    public function down(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->dropColumn([
                'email_opt_out',
                'sms_opt_out',
                'whatsapp_opt_out',
                'communication_preferences_updated_at',
            ]);
        });
    }
};
