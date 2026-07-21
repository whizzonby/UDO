<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('live_updates', function (Blueprint $table) {
            $table->string('severity')->default('info')->after('type');
            $table->string('audience')->default('all')->after('severity');
            $table->string('status')->default('open')->after('audience');
            $table->boolean('requires_action')->default(false)->after('bride_only');
            $table->timestamp('resolved_at')->nullable()->after('event_time');
        });
    }

    public function down(): void
    {
        Schema::table('live_updates', function (Blueprint $table) {
            $table->dropColumn(['severity', 'audience', 'status', 'requires_action', 'resolved_at']);
        });
    }
};
