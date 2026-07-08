<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('live_updates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->string('type')->default('announcement'); // announcement, moment, alert, photo, location_update
            $table->string('title')->nullable();
            $table->text('body');
            $table->string('image_url')->nullable();
            $table->boolean('pinned')->default(false);
            $table->boolean('visible_to_guests')->default(true);
            $table->boolean('bride_only')->default(false); // planner-facing only
            $table->timestamp('event_time')->nullable(); // when this happened
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('live_updates');
    }
};
