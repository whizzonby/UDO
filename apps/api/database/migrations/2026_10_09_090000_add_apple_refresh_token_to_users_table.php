<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Encrypted. Kept only so the Sign in with Apple grant can be
            // revoked when the account is deleted.
            $table->text('apple_refresh_token')->nullable()->after('auth_provider_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('apple_refresh_token');
        });
    }
};
