<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->boolean('show_seating')->default(false)->after('show_transport');
        });
    }

    public function down(): void
    {
        Schema::table('guest_experience_configs', function (Blueprint $table) {
            $table->dropColumn('show_seating');
        });
    }
};
