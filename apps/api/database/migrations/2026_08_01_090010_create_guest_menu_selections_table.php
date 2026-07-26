<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guest_menu_selections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('guest_id')->constrained()->cascadeOnDelete();
            $table->foreignId('menu_course_id')->constrained()->cascadeOnDelete();
            $table->foreignId('menu_course_option_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->unique(['guest_id', 'menu_course_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_menu_selections');
    }
};
