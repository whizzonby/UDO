<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_speeches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('speaker_name');
            $table->string('role')->nullable();
            $table->boolean('confirmed')->default(false);
            $table->unsignedInteger('duration_minutes')->nullable();
            $table->unsignedInteger('speaking_order')->nullable();
            $table->text('notes')->nullable();
            $table->string('draft_file_path')->nullable();
            $table->string('visibility')->default('shared'); // shared | private
            $table->date('reminder_date')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_speeches');
    }
};
