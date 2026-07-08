<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guest_experience_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            // Sections to show on guest portal
            $table->boolean('show_schedule')->default(true);
            $table->boolean('show_venue_map')->default(true);
            $table->boolean('show_accommodation')->default(true);
            $table->boolean('show_transport')->default(true);
            $table->boolean('show_dress_code')->default(true);
            $table->boolean('show_registry')->default(true);
            $table->boolean('show_gallery')->default(false);
            $table->boolean('show_live_feed')->default(false);
            $table->boolean('allow_photo_uploads')->default(false);
            $table->boolean('allow_messages')->default(false);
            // Guest-facing content
            $table->string('welcome_message')->nullable();
            $table->string('dress_code')->nullable();
            $table->text('dress_code_details')->nullable();
            $table->string('cover_image_url')->nullable();
            $table->string('theme_color')->nullable();
            // Feature flags
            $table->boolean('rsvp_enabled')->default(true);
            $table->boolean('meal_selection_enabled')->default(true);
            $table->boolean('plus_one_enabled')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_experience_configs');
    }
};
