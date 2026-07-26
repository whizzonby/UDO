<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_traditions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('person_responsible')->nullable();
            $table->text('required_items')->nullable();
            $table->string('timing')->nullable();
            $table->string('location')->nullable();
            $table->text('notes')->nullable();
            $table->string('visibility')->default('shared'); // shared | private
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_traditions');
    }
};
