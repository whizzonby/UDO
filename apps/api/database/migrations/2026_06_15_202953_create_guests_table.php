<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('first_name');
            $table->string('last_name')->nullable();
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->string('guest_group')->nullable();
            $table->json('custom_tags')->nullable();
            $table->boolean('vip_flag')->default(false);
            $table->string('attending_status')->default('pending'); // pending, yes, no
            $table->string('invite_status')->default('not_sent'); // not_sent, sent, opened, responded, failed
            $table->boolean('plus_one_allowed')->default(false);
            $table->integer('plus_one_count')->default(0);
            $table->string('meal_preference')->nullable();
            $table->text('allergies')->nullable();
            $table->text('dietary_note')->nullable();
            $table->boolean('travel_required')->default(false);
            $table->date('arrival_date')->nullable();
            $table->time('arrival_time')->nullable();
            $table->date('departure_date')->nullable();
            $table->time('departure_time')->nullable();
            $table->string('arrival_airport')->nullable();
            $table->unsignedBigInteger('hotel_assignment_id')->nullable();
            $table->unsignedBigInteger('transport_assignment_id')->nullable();
            $table->unsignedBigInteger('seating_assignment_id')->nullable();
            $table->string('guest_view_type')->default('pending');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guests');
    }
};
