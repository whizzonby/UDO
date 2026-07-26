<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('wedding_collaborators', function (Blueprint $table) {
            $table->boolean('is_decision_maker')->default(false)->after('permissions');
            $table->json('approval_categories')->nullable()->after('is_decision_maker');
        });
    }

    public function down(): void
    {
        Schema::table('wedding_collaborators', function (Blueprint $table) {
            $table->dropColumn(['is_decision_maker', 'approval_categories']);
        });
    }
};
