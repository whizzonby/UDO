<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guest_transport_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transport_group_id')->constrained()->cascadeOnDelete();
            $table->foreignId('guest_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['transport_group_id', 'guest_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_transport_assignments');
    }
};
