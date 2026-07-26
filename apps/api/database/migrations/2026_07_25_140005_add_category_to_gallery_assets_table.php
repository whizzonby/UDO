<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->string('category')->nullable()->after('board_name');
        });
    }

    public function down(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->dropColumn('category');
        });
    }
};
