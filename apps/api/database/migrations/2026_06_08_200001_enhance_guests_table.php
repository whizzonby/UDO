<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->string('relationship')->nullable()->after('group'); // bride_side, groom_side, mutual, other
            $table->string('age_group')->default('adult')->after('relationship'); // adult, child, baby
            $table->string('rsvp_status')->default('pending')->change(); // pending, attending, declined, maybe
            $table->boolean('plus_one_rsvp_attending')->nullable()->after('plus_one_name');
            $table->timestamp('invitation_sent_at')->nullable()->after('token');
            $table->timestamp('rsvp_responded_at')->nullable()->after('invitation_sent_at');
            $table->timestamp('checked_in_at')->nullable()->after('rsvp_responded_at');
            $table->string('address')->nullable()->after('checked_in_at');
            $table->string('language')->nullable()->after('address');
            $table->boolean('needs_transport')->default(false)->after('language');
            $table->boolean('needs_accommodation')->default(false)->after('needs_transport');
            $table->boolean('is_child')->default(false)->after('needs_accommodation');
            $table->unsignedInteger('sort_order')->default(0)->after('is_child');
        });
    }

    public function down(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->dropColumn([
                'relationship', 'age_group', 'plus_one_rsvp_attending',
                'invitation_sent_at', 'rsvp_responded_at', 'checked_in_at',
                'address', 'language', 'needs_transport', 'needs_accommodation',
                'is_child', 'sort_order',
            ]);
        });
    }
};
