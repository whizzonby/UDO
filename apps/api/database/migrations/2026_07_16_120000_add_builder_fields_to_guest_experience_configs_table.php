<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->string('publish_state')->default('published')->after('wedding_id');
            $table->json('layout_order')->nullable()->after('publish_state');
            $table->json('access_rules')->nullable()->after('layout_order');
            $table->timestamp('published_at')->nullable()->after('access_rules');
        });
    }

    public function down(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->dropColumn(['publish_state', 'layout_order', 'access_rules', 'published_at']);
        });
    }
};
