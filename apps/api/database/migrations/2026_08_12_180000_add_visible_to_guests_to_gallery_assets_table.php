<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            // Kept separate from `approved` (a moderation flag for guest
            // uploads) so hiding a photo from the guest link never silently
            // un-approves it elsewhere in the app.
            $table->boolean('visible_to_guests')->default(true)->after('approved');
        });
    }

    public function down(): void
    {
        Schema::table('gallery_assets', function (Blueprint $table) {
            $table->dropColumn('visible_to_guests');
        });
    }
};
