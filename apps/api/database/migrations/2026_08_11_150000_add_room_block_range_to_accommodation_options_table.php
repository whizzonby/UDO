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
        Schema::table('accommodation_options', function (Blueprint $table) {
            $table->unsignedInteger('room_block_start')->nullable();
            $table->unsignedInteger('room_block_end')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('accommodation_options', function (Blueprint $table) {
            $table->dropColumn(['room_block_start', 'room_block_end']);
        });
    }
};
