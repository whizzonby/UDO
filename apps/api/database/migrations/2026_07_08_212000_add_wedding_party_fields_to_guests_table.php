<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Only meaningful for guests with guest_group = 'wedding_party', but
     * kept on the shared guests table rather than a parallel membership
     * table — a wedding party member is a guest first, per the existing
     * People tab pattern (POST /guests with guest_group: wedding_party).
     */
    public function up(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->string('wedding_party_role')->nullable()->after('guest_group');
            $table->string('attire_status')->nullable()->after('wedding_party_role');
            $table->string('rehearsal_status')->nullable()->after('attire_status');
        });
    }

    public function down(): void
    {
        Schema::table('guests', function (Blueprint $table) {
            $table->dropColumn(['wedding_party_role', 'attire_status', 'rehearsal_status']);
        });
    }
};
