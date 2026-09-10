<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Discount codes for the Stripe web checkout (the single $45 "lifetime"
 * purchase in CheckoutController). Native IAP price is set by Apple/Google's
 * own store, so coupons only ever apply to the web flow.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code', 40)->unique();
            $table->enum('type', ['percent', 'fixed'])->default('percent');
            $table->unsignedInteger('value'); // percent: 1-100, fixed: cents off
            $table->unsignedInteger('max_redemptions')->nullable(); // null = unlimited
            $table->unsignedInteger('redeemed_count')->default(0);
            $table->timestamp('expires_at')->nullable();
            $table->enum('status', ['active', 'disabled'])->default('active');
            $table->string('note', 500)->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index('status');
            $table->index('expires_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coupons');
    }
};
