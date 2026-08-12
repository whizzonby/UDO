<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('weddings', function (Blueprint $table) {
            $table->string('invite_code', 8)->nullable()->unique()->after('slug');
        });

        DB::table('weddings')->orderBy('id')->select('id')->chunkById(100, function ($weddings) {
            foreach ($weddings as $wedding) {
                do {
                    $code = strtoupper(Str::random(6));
                } while (DB::table('weddings')->where('invite_code', $code)->exists());

                DB::table('weddings')->where('id', $wedding->id)->update(['invite_code' => $code]);
            }
        });
    }

    public function down(): void
    {
        Schema::table('weddings', function (Blueprint $table) {
            $table->dropColumn('invite_code');
        });
    }
};
