<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_guestbooks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('type')->nullable(); // physical | digital | both
            $table->string('vendor_name')->nullable();
            $table->string('setup_location')->nullable();
            $table->text('instructions')->nullable();
            $table->string('status')->nullable();
            $table->boolean('digital_enabled')->default(false);
            $table->timestamps();

            $table->unique('wedding_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_guestbooks');
    }
};
