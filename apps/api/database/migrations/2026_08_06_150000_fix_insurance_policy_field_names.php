<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * The mobile "Add insurance policy" form has always sent premium_amount,
 * deductible_amount, contact_name, contact_phone, and claim_phone, but the
 * backend validated (and the model stored) premium, deductible, and a single
 * contact_number — so all of those fields were silently dropped on every
 * save. Renaming/adding columns here to match what the form actually
 * collects, rather than trimming the form down to the lesser schema.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('insurance_policies', function (Blueprint $table) {
            $table->renameColumn('premium', 'premium_amount');
            $table->renameColumn('deductible', 'deductible_amount');
            $table->renameColumn('contact_number', 'contact_phone');
        });

        Schema::table('insurance_policies', function (Blueprint $table) {
            $table->string('contact_name')->nullable()->after('status');
            $table->string('claim_phone')->nullable()->after('contact_phone');
        });
    }

    public function down(): void
    {
        Schema::table('insurance_policies', function (Blueprint $table) {
            $table->dropColumn(['contact_name', 'claim_phone']);
        });

        Schema::table('insurance_policies', function (Blueprint $table) {
            $table->renameColumn('premium_amount', 'premium');
            $table->renameColumn('deductible_amount', 'deductible');
            $table->renameColumn('contact_phone', 'contact_number');
        });
    }
};
