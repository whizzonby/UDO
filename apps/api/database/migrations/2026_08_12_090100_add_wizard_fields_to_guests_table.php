<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->string('plus_one_name')->nullable()->after('plus_one_count');
            $table->string('plus_one_email')->nullable()->after('plus_one_name');
            $table->string('song_request')->nullable()->after('notes');
            $table->boolean('wants_accommodation')->nullable()->after('travel_required');
        });
    }

    public function down(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->dropColumn(['plus_one_name', 'plus_one_email', 'song_request', 'wants_accommodation']);
        });
    }
};
