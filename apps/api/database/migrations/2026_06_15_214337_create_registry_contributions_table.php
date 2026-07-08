<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('registry_contributions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('registry_item_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('guest_id')->nullable()->constrained()->nullOnDelete();
            $table->string('contributor_name');
            $table->string('contributor_email')->nullable();
            $table->decimal('amount', 10, 2)->nullable(); // for cash funds
            $table->integer('quantity')->default(1); // for physical items
            $table->string('stripe_payment_intent_id')->nullable();
            $table->string('payment_status')->default('pending'); // pending, completed, refunded
            $table->text('message')->nullable(); // personal note from contributor
            $table->boolean('thank_you_sent')->default(false);
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registry_contributions');
    }
};
