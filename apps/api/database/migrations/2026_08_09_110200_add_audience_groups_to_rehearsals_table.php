<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rehearsals', function (Blueprint $table) {
            $table->json('audience_groups')->nullable()->after('audience');
        });
    }

    public function down(): void
    {
        Schema::table('rehearsals', function (Blueprint $table) {
            $table->dropColumn('audience_groups');
        });
    }
};
