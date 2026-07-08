<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('seating_seats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seating_table_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('guest_id')->nullable()->constrained()->nullOnDelete();
            $table->integer('seat_number');
            $table->string('label')->nullable(); // optional seat label
            $table->timestamps();

            $table->unique(['seating_table_id', 'seat_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('seating_seats');
    }
};
