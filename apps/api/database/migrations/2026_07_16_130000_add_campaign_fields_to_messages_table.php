<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->string('campaign_name')->nullable()->after('created_by');
            $table->string('campaign_type')->nullable()->after('campaign_name');
            $table->string('template_id')->nullable()->after('campaign_type');
        });
    }

    public function down(): void
    {
        Schema::table('messages', function (Blueprint $table) {
            $table->dropColumn(['campaign_name', 'campaign_type', 'template_id']);
        });
    }
};
