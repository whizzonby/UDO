<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('weddings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('partner_one_name');
            $table->string('partner_two_name')->nullable();
            $table->date('wedding_date')->nullable();
            $table->boolean('date_not_set')->default(false);
            $table->string('venue_name')->nullable();
            $table->string('venue_address')->nullable();
            $table->string('guest_count_range')->nullable();
            $table->string('currency', 3)->default('USD');
            $table->decimal('total_budget', 12, 2)->nullable();
            $table->string('cover_photo_url')->nullable();
            $table->enum('status', ['planning', 'live', 'completed'])->default('planning');
            $table->string('timezone')->default('UTC');
            $table->json('settings')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('weddings');
    }
};
