<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->boolean('is_saved')->default(false)->after('is_featured');
        });
    }

    public function down(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->dropColumn('is_saved');
        });
    }
};
