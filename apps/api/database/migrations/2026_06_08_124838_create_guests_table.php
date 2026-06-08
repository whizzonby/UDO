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
        Schema::create('guests', function (Blueprint $table) {
            $table->id();
            $table->uuid('wedding_id');
            $table->foreign('wedding_id')->references('id')->on('weddings')->cascadeOnDelete();
            $table->string('first_name');
            $table->string('last_name')->nullable();
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->enum('rsvp_status', ['pending', 'attending', 'declined', 'maybe'])->default('pending');
            $table->string('group')->nullable();
            $table->boolean('is_vip')->default(false);
            $table->string('dietary_requirements')->nullable();
            $table->boolean('plus_one_allowed')->default(false);
            $table->string('plus_one_name')->nullable();
            $table->string('token')->unique()->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('guests');
    }
};
