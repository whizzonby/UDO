<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('honeymoon_trips', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('destination')->nullable();
            $table->date('departure_date')->nullable();
            $table->date('return_date')->nullable();
            $table->string('status')->nullable();
            $table->text('notes')->nullable();
            $table->json('checklist')->nullable(); // {"passport_validity": true, "visa_requirements": false, ...}
            $table->timestamps();

            $table->unique('wedding_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('honeymoon_trips');
    }
};
