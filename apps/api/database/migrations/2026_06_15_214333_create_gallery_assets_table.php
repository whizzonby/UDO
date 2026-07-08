<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gallery_assets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->foreignId('uploaded_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('uploaded_by_guest_id')->nullable()->constrained('guests')->nullOnDelete();
            $table->string('type')->default('photo'); // photo, video
            $table->string('source')->default('upload'); // upload, pinterest, instagram
            $table->string('url');
            $table->string('thumbnail_url')->nullable();
            $table->string('original_filename')->nullable();
            $table->bigInteger('file_size_bytes')->nullable();
            $table->string('album')->nullable(); // moments, inspiration, guest_uploads, archive
            $table->string('caption')->nullable();
            $table->boolean('is_featured')->default(false);
            $table->boolean('approved')->default(true); // guest uploads need moderation
            $table->string('pinterest_source_url')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gallery_assets');
    }
};
