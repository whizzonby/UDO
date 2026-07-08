<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transport_groups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // e.g. "Airport Shuttle - Friday AM"
            $table->string('type')->default('shuttle'); // shuttle, coach, minibus, car, private
            $table->string('pickup_location')->nullable();
            $table->string('dropoff_location')->nullable();
            $table->dateTime('departure_time')->nullable();
            $table->integer('capacity')->nullable();
            $table->integer('assigned_count')->default(0);
            $table->string('driver_name')->nullable();
            $table->string('driver_phone')->nullable();
            $table->string('vehicle_registration')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transport_groups');
    }
};
