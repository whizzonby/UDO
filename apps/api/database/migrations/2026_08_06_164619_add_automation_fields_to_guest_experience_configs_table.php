<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->boolean('auto_rsvp_reminder_enabled')->default(false);
            $table->unsignedTinyInteger('auto_rsvp_reminder_days')->default(5);
            $table->boolean('auto_thank_you_enabled')->default(false);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->dropColumn(['auto_rsvp_reminder_enabled', 'auto_rsvp_reminder_days', 'auto_thank_you_enabled']);
        });
    }
};
