<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('weddings', function (Blueprint $table) {
            $table->text('pinterest_access_token')->nullable();
            $table->text('pinterest_refresh_token')->nullable();
            $table->timestamp('pinterest_token_expires_at')->nullable();
            $table->string('pinterest_username')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('weddings', function (Blueprint $table) {
            $table->dropColumn(['pinterest_access_token', 'pinterest_refresh_token', 'pinterest_token_expires_at', 'pinterest_username']);
        });
    }
};
