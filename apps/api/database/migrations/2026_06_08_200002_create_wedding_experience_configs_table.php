<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wedding_experience_configs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->boolean('is_published')->default(false);
            $table->text('welcome_message')->nullable();
            $table->json('sections_enabled')->nullable();
            $table->string('theme_accent_color', 7)->default('#FF4D8C');
            $table->string('custom_domain')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wedding_experience_configs');
    }
};
