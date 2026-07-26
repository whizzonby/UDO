<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('memory_vows', function (Blueprint $table) {
            $table->timestamp('viewed_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('memory_vows', function (Blueprint $table) {
            $table->dropColumn('viewed_at');
        });
    }
};
