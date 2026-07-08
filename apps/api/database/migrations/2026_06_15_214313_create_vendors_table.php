<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('name'); // business name
            $table->string('contact_person')->nullable();
            $table->string('category'); // venue, catering, photography, florals, music, hair_makeup, transport, attire, etc.
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->string('website')->nullable();
            $table->string('instagram')->nullable();
            $table->decimal('quoted_price', 10, 2)->nullable();
            $table->decimal('deposit_paid', 10, 2)->default(0);
            $table->decimal('balance_due', 10, 2)->default(0);
            $table->date('deposit_due_date')->nullable();
            $table->date('balance_due_date')->nullable();
            $table->string('booking_status')->default('enquired'); // enquired, shortlisted, booked, paid, cancelled
            $table->boolean('contract_signed')->default(false);
            $table->string('contract_file_url')->nullable();
            $table->boolean('on_timeline')->default(false);
            $table->boolean('priority')->default(false);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendors');
    }
};
