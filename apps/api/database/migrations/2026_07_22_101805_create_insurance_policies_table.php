<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('insurance_policies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('provider');
            $table->string('policy_number')->nullable();
            $table->string('policy_type')->nullable();
            $table->decimal('coverage_amount', 12, 2)->nullable();
            $table->decimal('premium', 12, 2)->nullable();
            $table->decimal('deductible', 12, 2)->nullable();
            $table->date('purchase_date')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->string('status')->default('active'); // active, expired, cancelled
            $table->string('contact_number')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('insurance_policies');
    }
};
