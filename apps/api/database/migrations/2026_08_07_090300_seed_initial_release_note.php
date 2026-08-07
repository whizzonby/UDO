<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        DB::table('release_notes')->insert([
            'version' => '1.0.0',
            'title' => 'Udo launches',
            'body' => "The first release of Udo: guest management and RSVPs, budget and vendor tracking, timeline planning, the live day-of hub, a shared photo gallery, and a guest-facing wedding portal.",
            'released_at' => $now->toDateString(),
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    public function down(): void
    {
        DB::table('release_notes')->where('version', '1.0.0')->delete();
    }
};
