<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_vows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('draft_text')->nullable();
            $table->string('file_path')->nullable();
            $table->boolean('is_private')->default(true);
            $table->boolean('is_final')->default(false);
            $table->string('printing_status')->nullable();
            $table->boolean('has_backup')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_vows');
    }
};
