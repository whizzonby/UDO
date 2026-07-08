<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('seating_tables', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // e.g. "Table 1", "Head Table", "Family Table"
            $table->string('shape')->default('round'); // round, rectangular, oval, custom
            $table->integer('capacity');
            $table->integer('assigned_count')->default(0);
            $table->decimal('pos_x', 8, 2)->default(0); // canvas position for drag-drop
            $table->decimal('pos_y', 8, 2)->default(0);
            $table->string('event_section')->nullable(); // main room, garden, etc.
            $table->text('notes')->nullable();
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('seating_tables');
    }
};
