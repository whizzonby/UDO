<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rehearsals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wedding_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('color')->nullable();
            $table->string('location')->nullable();
            $table->string('location_place_id')->nullable();
            $table->text('description')->nullable();
            $table->date('event_date');
            $table->time('start_time')->nullable();
            $table->time('end_time')->nullable();
            $table->string('timezone')->nullable();
            $table->string('audience')->default('wedding_party'); // all, wedding_party, family, travelling, vip, vendors, selected, private
            $table->json('attendee_guest_ids')->nullable();
            $table->string('dress_code')->nullable();
            $table->json('bring_items')->nullable();
            $table->text('notes')->nullable();
            $table->boolean('add_to_timeline')->default(true);
            $table->foreignId('timeline_item_id')->nullable()->constrained('timeline_items')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rehearsals');
    }
};
