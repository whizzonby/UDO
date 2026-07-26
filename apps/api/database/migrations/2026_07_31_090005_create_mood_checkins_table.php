<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mood_checkins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('mood');
            $table->timestamp('created_at')->useCurrent();
            $table->index(['wedding_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mood_checkins');
    }
};
