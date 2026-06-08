<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('registry_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2)->nullable();
            $table->string('url')->nullable();
            $table->string('image_url')->nullable();
            $table->string('category')->nullable();
            $table->boolean('is_claimed')->default(false);
            $table->string('claimed_by_name')->nullable();
            $table->boolean('thank_you_sent')->default(false);
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('registry_cash_funds', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title')->default('Our Honeymoon Fund');
            $table->text('description')->nullable();
            $table->decimal('target_amount', 10, 2)->nullable();
            $table->boolean('is_active')->default(false);
            $table->string('share_token', 32)->unique();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registry_cash_funds');
        Schema::dropIfExists('registry_items');
    }
};
