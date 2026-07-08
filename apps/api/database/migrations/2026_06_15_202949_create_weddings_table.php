<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weddings', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->string('title')->nullable();
            $table->string('couple_name_primary');
            $table->string('couple_name_secondary')->nullable();
            $table->date('event_date')->nullable();
            $table->string('timezone')->default('UTC');
            $table->string('city')->nullable();
            $table->string('country')->nullable();
            $table->string('primary_venue_name')->nullable();
            $table->text('primary_venue_address')->nullable();
            $table->date('rsvp_deadline')->nullable();
            $table->string('status')->default('planning'); // planning, final_week, live, completed, post_wedding
            $table->foreignId('owner_user_id')->constrained('users')->cascadeOnDelete();
            $table->json('settings')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weddings');
    }
};
