<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * `priority` was a boolean but the API has always validated it as
     * low/medium/high — every non-empty value was silently coerced to
     * `true`, so real priority data was never actually stored. Rebuilt as
     * a plain string column rather than using Schema::change() (needs
     * doctrine/dbal and doesn't behave uniformly across sqlite/mysql).
     */
    public function up(): void
    {
        Schema::table('vendors', function (Blueprint $table) {
            $table->string('priority_level')->nullable()->after('priority');
        });

        DB::table('vendors')->where('priority', true)->update(['priority_level' => 'high']);
        DB::table('vendors')->where('priority', false)->update(['priority_level' => 'medium']);

        Schema::table('vendors', function (Blueprint $table) {
            $table->dropColumn('priority');
        });

        Schema::table('vendors', function (Blueprint $table) {
            $table->renameColumn('priority_level', 'priority');
        });
    }

    public function down(): void
    {
        Schema::table('vendors', function (Blueprint $table) {
            $table->boolean('priority_bool')->default(false)->after('priority');
        });

        DB::table('vendors')->where('priority', 'high')->update(['priority_bool' => true]);

        Schema::table('vendors', function (Blueprint $table) {
            $table->dropColumn('priority');
        });

        Schema::table('vendors', function (Blueprint $table) {
            $table->renameColumn('priority_bool', 'priority');
        });
    }
};
