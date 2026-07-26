<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('honeymoon_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('honeymoon_trip_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // flight, accommodation, activity
            $table->string('title');
            $table->date('date')->nullable();
            $table->decimal('cost', 12, 2)->nullable();
            $table->json('details')->nullable(); // type-specific fields (airline/flight_number, property/check_in, location/booking_status, ...)
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('honeymoon_items');
    }
};
