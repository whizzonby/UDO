<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rehearsals', function (Blueprint $table) {
            $table->json('schedule_items')->nullable()->after('bring_items');
        });
    }

    public function down(): void
    {
        Schema::table('rehearsals', function (Blueprint $table) {
            $table->dropColumn('schedule_items');
        });
    }
};
