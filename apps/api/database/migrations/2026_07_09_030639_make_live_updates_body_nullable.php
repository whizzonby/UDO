<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * `body` was NOT NULL while the API/mobile app treat `title` as the
     * required field and `body` as optional — every quick "title-only"
     * update throws a DB integrity error. SQLite has no MODIFY COLUMN
     * without doctrine/dbal, so add-copy-drop-rename instead.
     */
    public function up(): void
    {
        Schema::table('live_updates', function (Blueprint $table) {
            $table->text('body_new')->nullable()->after('body');
        });

        DB::statement('UPDATE live_updates SET body_new = body');

        Schema::table('live_updates', function (Blueprint $table) {
            $table->dropColumn('body');
        });

        Schema::table('live_updates', function (Blueprint $table) {
            $table->renameColumn('body_new', 'body');
        });
    }

    public function down(): void
    {
        Schema::table('live_updates', function (Blueprint $table) {
            $table->text('body_old')->nullable()->after('body');
        });

        DB::statement('UPDATE live_updates SET body_old = body');
        DB::statement("UPDATE live_updates SET body_old = '' WHERE body_old IS NULL");

        Schema::table('live_updates', function (Blueprint $table) {
            $table->dropColumn('body');
        });

        Schema::table('live_updates', function (Blueprint $table) {
            $table->renameColumn('body_old', 'body');
        });
    }
};
