<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('faqs', function (Blueprint $table) {
            $table->id();
            $table->string('question');
            $table->text('answer');
            $table->string('category')->default('general'); // general, pricing, features, technical, planning
            $table->integer('sort_order')->default(0);
            $table->boolean('is_visible')->default(true);
            $table->boolean('featured')->default(false);
            $table->timestamps();

            $table->index(['category', 'is_visible']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('faqs');
    }
};
