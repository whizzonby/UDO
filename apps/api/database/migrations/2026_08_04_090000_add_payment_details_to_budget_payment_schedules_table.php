<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('budget_payment_schedules', function (Blueprint $table) {
            $table->string('payment_method')->nullable()->after('status');
            $table->string('reference')->nullable()->after('payment_method');
            $table->string('receipt_path')->nullable()->after('reference');
        });
    }

    public function down(): void
    {
        Schema::table('budget_payment_schedules', function (Blueprint $table) {
            $table->dropColumn(['payment_method', 'reference', 'receipt_path']);
        });
    }
};
