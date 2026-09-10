<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coupon_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('coupon_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('subscription_id')->nullable()->constrained()->nullOnDelete();
            $table->string('stripe_checkout_session_id', 255)->nullable();
            $table->unsignedInteger('amount_discounted_cents')->default(0);
            $table->timestamp('redeemed_at');
            $table->timestamps();

            // One redemption per user per coupon.
            $table->unique(['coupon_id', 'user_id']);
            $table->index('redeemed_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coupon_redemptions');
    }
};
