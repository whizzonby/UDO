<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reminders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->date('due_date')->nullable();
            $table->string('priority')->default('medium'); // low, medium, high
            $table->string('status')->default('pending'); // pending, completed
            $table->string('source')->default('manual'); // manual, auto
            $table->string('source_key')->nullable(); // e.g. budget_item:12 — stable key for auto-generated reminders
            $table->string('source_description')->nullable(); // e.g. "Created from Florist final payment date."
            $table->timestamps();

            $table->unique(['wedding_id', 'source_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reminders');
    }
};
