<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invitations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title_line')->nullable();
            $table->text('invitation_text')->nullable();
            $table->string('date_text')->nullable();
            $table->string('venue_text')->nullable();
            $table->text('optional_quote')->nullable();
            $table->string('rsvp_deadline_text')->nullable();
            $table->string('cover_image_url')->nullable();
            $table->string('template_id')->nullable();
            $table->string('theme_id')->nullable();
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invitations');
    }
};
