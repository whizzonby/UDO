<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('seating_tables', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->unsignedTinyInteger('capacity')->default(8);
            $table->enum('shape', ['round', 'rectangular', 'oval'])->default('round');
            $table->string('section')->nullable();
            $table->string('color', 7)->default('#FF4D8C');
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('table_assignments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('table_id')->references('id')->on('seating_tables')->cascadeOnDelete();
            $table->foreignUuid('guest_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('seat_number')->nullable();
            $table->timestamps();
            $table->unique('guest_id'); // one seat per guest globally
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('table_assignments');
        Schema::dropIfExists('seating_tables');
    }
};
