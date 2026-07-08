<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('accommodation_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // Hotel XYZ
            $table->string('type')->default('hotel'); // hotel, bnb, villa, guesthouse, airbnb
            $table->text('address')->nullable();
            $table->string('city')->nullable();
            $table->string('country')->nullable();
            $table->decimal('price_per_night', 10, 2)->nullable();
            $table->string('currency')->default('USD');
            $table->integer('total_rooms_blocked')->nullable();
            $table->integer('rooms_assigned')->default(0);
            $table->string('booking_code')->nullable(); // group discount code
            $table->string('contact_name')->nullable();
            $table->string('contact_phone')->nullable();
            $table->string('contact_email')->nullable();
            $table->string('website')->nullable();
            $table->decimal('distance_from_venue_km', 6, 2)->nullable();
            $table->date('check_in_date')->nullable();
            $table->date('check_out_date')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('accommodation_options');
    }
};
