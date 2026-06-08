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
        Schema::create('budget_items', function (Blueprint $table) {
            $table->id();
            $table->uuid('wedding_id');
            $table->foreign('wedding_id')->references('id')->on('weddings')->cascadeOnDelete();
            $table->foreignId('vendor_id')->nullable()->constrained()->nullOnDelete();
            $table->string('category');
            $table->string('name');
            $table->decimal('budgeted_amount', 12, 2);
            $table->decimal('actual_amount', 12, 2)->nullable();
            $table->enum('status', ['planned', 'deposit_paid', 'fully_paid'])->default('planned');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('budget_items');
    }
};
