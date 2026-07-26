<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->boolean('is_elderly')->default(false)->after('vip_flag');
            $table->boolean('accessibility_needs')->default(false)->after('is_elderly');
        });
    }

    public function down(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->dropColumn(['is_elderly', 'accessibility_needs']);
        });
    }
};
