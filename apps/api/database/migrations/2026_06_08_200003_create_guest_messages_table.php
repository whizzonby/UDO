<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('guest_messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('subject')->nullable();
            $table->text('body');
            $table->enum('channel', ['in_app', 'email', 'sms'])->default('in_app');
            $table->json('recipient_filter')->nullable();
            $table->unsignedInteger('recipient_count')->default(0);
            $table->enum('status', ['draft', 'sent'])->default('sent');
            $table->timestamp('sent_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('guest_messages');
    }
};
