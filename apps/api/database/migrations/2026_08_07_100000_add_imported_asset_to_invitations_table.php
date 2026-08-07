<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('invitations', function (Blueprint $table) {
            $table->string('imported_asset_url')->nullable()->after('cover_image_url');
            $table->string('imported_asset_type')->nullable()->after('imported_asset_url');
        });
    }

    public function down(): void
    {
        Schema::table('invitations', function (Blueprint $table) {
            $table->dropColumn(['imported_asset_url', 'imported_asset_type']);
        });
    }
};
