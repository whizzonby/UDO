<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->string('uploaded_by_name')->nullable()->after('uploaded_by_guest_id');
            $table->string('board_name')->nullable()->after('album');
        });
    }

    public function down(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->dropColumn(['uploaded_by_name', 'board_name']);
        });
    }
};
