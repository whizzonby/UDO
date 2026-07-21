<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('smart_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('key');
            $table->string('alert_type');
            $table->string('severity')->default('medium');
            $table->string('status')->default('active');
            $table->string('target')->nullable();
            $table->string('title');
            $table->text('body')->nullable();
            $table->string('action_label')->nullable();
            $table->string('action_url')->nullable();
            $table->timestamp('trigger_at')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->unique(['wedding_id', 'key']);
            $table->index(['wedding_id', 'status', 'severity']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('smart_alerts');
    }
};
