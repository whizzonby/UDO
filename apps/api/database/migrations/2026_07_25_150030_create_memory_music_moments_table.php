<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_music_moments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('first_dance_song')->nullable();
            $table->string('parent_dance_song')->nullable();
            $table->string('entrance_music')->nullable();
            $table->string('exit_song')->nullable();
            $table->string('cake_cutting_song')->nullable();
            $table->string('bouquet_toss_song')->nullable();
            $table->json('other_moments')->nullable(); // [{"label": "...", "song": "..."}]
            $table->timestamps();

            $table->unique('wedding_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_music_moments');
    }
};
