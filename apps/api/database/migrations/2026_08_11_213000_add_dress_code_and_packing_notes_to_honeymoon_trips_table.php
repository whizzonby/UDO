<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('honeymoon_trips', function (Blueprint $table) {
            $table->string('dress_code')->nullable();
            $table->text('packing_notes')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('honeymoon_trips', function (Blueprint $table) {
            $table->dropColumn(['dress_code', 'packing_notes']);
        });
    }
};
