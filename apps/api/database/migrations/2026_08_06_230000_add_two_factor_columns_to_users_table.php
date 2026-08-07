<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('two_factor_enabled')->default(false)->after('password');
            $table->string('two_factor_code')->nullable()->after('two_factor_enabled');
            $table->string('two_factor_challenge_token')->nullable()->after('two_factor_code');
            $table->timestamp('two_factor_expires_at')->nullable()->after('two_factor_challenge_token');
            $table->unsignedTinyInteger('two_factor_attempts')->default(0)->after('two_factor_expires_at');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'two_factor_enabled',
                'two_factor_code',
                'two_factor_challenge_token',
                'two_factor_expires_at',
                'two_factor_attempts',
            ]);
        });
    }
};
