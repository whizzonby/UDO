<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('onboarding_data', function (Blueprint $table) {
            $table->id();
            $table->uuid('wedding_id')->unique();
            $table->foreign('wedding_id')->references('id')->on('weddings')->cascadeOnDelete();
            // Role & planning approach
            $table->string('user_role')->nullable();
            $table->string('planning_approach')->nullable();
            $table->string('decision_style')->nullable();
            $table->string('planning_stage')->nullable();
            // Wedding structure
            $table->string('wedding_type')->nullable();
            $table->string('season')->nullable();
            $table->string('date_flexibility')->nullable();
            $table->string('time_of_day')->nullable();
            $table->json('event_structures')->nullable();
            // Venue & logistics
            $table->string('venue_status')->nullable();
            $table->string('guest_travel_profile')->nullable();
            $table->json('support_needed')->nullable();
            // Food & experience
            $table->json('food_experience')->nullable();
            $table->json('dietary_needs')->nullable();
            $table->json('entertainment')->nullable();
            // Ceremony details
            $table->json('speeches_config')->nullable();
            $table->string('wedding_insurance')->nullable();
            // Guest & communication
            $table->string('guest_count_range')->nullable();
            $table->string('guest_experience_style')->nullable();
            $table->string('communication_style')->nullable();
            $table->json('invitation_channels')->nullable();
            // Priorities & style
            $table->json('planning_priorities')->nullable();
            $table->json('wedding_vibes')->nullable();
            $table->string('budget_range')->nullable();
            // Completion
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('onboarding_data');
    }
};
