<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->string('platform')->nullable()->after('stripe_checkout_session_id');
            $table->string('platform_transaction_id')->nullable()->after('platform');
        });

        DB::table('subscriptions')->whereNull('platform')->update(['platform' => 'stripe']);
    }

    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropColumn(['platform', 'platform_transaction_id']);
        });
    }
};
