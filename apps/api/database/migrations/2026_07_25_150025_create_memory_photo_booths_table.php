<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('memory_photo_booths', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('vendor_name')->nullable();
            $table->string('setup_time')->nullable();
            $table->string('location')->nullable();
            $table->text('props')->nullable();
            $table->string('backdrop')->nullable();
            $table->string('sharing_method')->nullable();
            $table->boolean('guest_access')->default(false);
            $table->string('status')->nullable();
            $table->timestamps();

            $table->unique('wedding_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('memory_photo_booths');
    }
};
