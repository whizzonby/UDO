<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('honeymoon_trips', function (Blueprint $table) {
            $table->decimal('total_budget', 12, 2)->nullable()->after('return_date');
            $table->string('cover_photo_path')->nullable()->after('destination');
        });

        Schema::table('honeymoon_items', function (Blueprint $table) {
            $table->string('status')->default('pending')->after('type');
            $table->foreignId('budget_item_id')->nullable()->after('cost')->constrained('budget_items')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('honeymoon_items', function (Blueprint $table) {
            $table->dropConstrainedForeignId('budget_item_id');
            $table->dropColumn('status');
        });

        Schema::table('honeymoon_trips', function (Blueprint $table) {
            $table->dropColumn(['total_budget', 'cover_photo_path']);
        });
    }
};
