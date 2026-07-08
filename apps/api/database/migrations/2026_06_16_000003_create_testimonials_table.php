<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('testimonials', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->nullable()->constrained()->nullOnDelete();
            $table->string('couple_names');
            $table->date('wedding_date')->nullable();
            $table->string('location')->nullable();
            $table->text('quote');
            $table->string('photo_url')->nullable();
            $table->unsignedTinyInteger('rating')->default(5);
            $table->boolean('approved')->default(false);
            $table->boolean('featured')->default(false);
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['approved', 'featured']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('testimonials');
    }
};
