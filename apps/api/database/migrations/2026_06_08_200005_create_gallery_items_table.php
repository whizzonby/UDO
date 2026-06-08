<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gallery_items', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['inspiration', 'memory'])->default('inspiration');
            $table->string('title')->nullable();
            $table->text('caption')->nullable();
            $table->string('image_url');
            $table->string('category')->nullable(); // e.g. venue, florals, decor, attire, food
            $table->boolean('is_featured')->default(false);
            $table->string('source_url')->nullable(); // original web URL for inspiration pins
            $table->string('uploaded_by')->nullable(); // guest name for memory uploads
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gallery_items');
    }
};
