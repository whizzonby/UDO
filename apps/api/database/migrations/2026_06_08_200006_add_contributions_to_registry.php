<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('registry_cash_funds', function (Blueprint $table) {
            $table->decimal('raised_amount', 10, 2)->default(0)->after('target_amount');
        });

        Schema::create('cash_fund_contributions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('cash_fund_id')->constrained()->cascadeOnDelete();
            $table->string('stripe_session_id', 128)->unique()->nullable();
            $table->string('stripe_payment_intent_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('usd');
            $table->enum('status', ['pending', 'paid', 'failed'])->default('pending');
            $table->string('contributor_name')->nullable();
            $table->string('contributor_email')->nullable();
            $table->text('message')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cash_fund_contributions');
        Schema::table('registry_cash_funds', function (Blueprint $table) {
            $table->dropColumn('raised_amount');
        });
    }
};
