<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Allow null email for Apple users who hide it
            $table->string('email')->nullable()->change();
            $table->string('social_provider', 20)->nullable()->after('avatar_url');
            $table->string('social_id', 255)->nullable()->after('social_provider');
            $table->unique(['social_provider', 'social_id'], 'users_social_unique');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropUnique('users_social_unique');
            $table->dropColumn(['social_provider', 'social_id']);
            $table->string('email')->nullable(false)->change();
        });
    }
};
