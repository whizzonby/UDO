<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('registry_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('type')->default('item'); // item, cash_fund, experience
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('image_url')->nullable();
            $table->string('store_name')->nullable();
            $table->string('store_url')->nullable();
            $table->decimal('price', 10, 2)->nullable();
            $table->string('currency')->default('USD');
            $table->integer('quantity_requested')->default(1);
            $table->integer('quantity_purchased')->default(0);
            $table->boolean('is_priority')->default(false);
            $table->boolean('is_visible')->default(true);
            // Cash fund specific
            $table->decimal('fund_goal', 10, 2)->nullable();
            $table->decimal('fund_raised', 10, 2)->default(0);
            $table->string('stripe_payment_link')->nullable();
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registry_items');
    }
};
