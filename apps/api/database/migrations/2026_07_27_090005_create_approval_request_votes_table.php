<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('approval_request_votes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('approval_request_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wedding_collaborator_id')->constrained()->cascadeOnDelete();
            $table->string('decision');
            $table->text('note')->nullable();
            $table->timestamps();

            $table->unique(['approval_request_id', 'wedding_collaborator_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('approval_request_votes');
    }
};
