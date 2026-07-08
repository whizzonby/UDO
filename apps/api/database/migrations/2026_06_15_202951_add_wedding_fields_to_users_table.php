<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('first_name')->nullable()->after('name');
            $table->string('last_name')->nullable()->after('first_name');
            $table->string('phone')->nullable()->after('email');
            $table->string('avatar_url')->nullable();
            $table->string('auth_provider')->default('email');
            $table->string('auth_provider_id')->nullable();
            $table->unsignedBigInteger('active_wedding_id')->nullable();
            $table->boolean('onboarding_completed')->default(false);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['first_name', 'last_name', 'phone', 'avatar_url', 'auth_provider', 'auth_provider_id', 'active_wedding_id', 'onboarding_completed']);
        });
    }
};
