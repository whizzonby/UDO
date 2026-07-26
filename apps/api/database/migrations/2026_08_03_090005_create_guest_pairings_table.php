<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guest_pairings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('guest_id')->constrained('guests')->cascadeOnDelete();
            $table->foreignId('related_guest_id')->constrained('guests')->cascadeOnDelete();
            $table->enum('type', ['couple', 'do_not_seat']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_pairings');
    }
};
