<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Records taps on the "Get the App / Google Play" links across the marketing
 * site, so acquisition can be seen in the admin panel alongside user and
 * revenue data. `click_id` is reserved for phase-2 install attribution via
 * the Google Play Install Referrer.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('store_link_clicks', function (Blueprint $table) {
            $table->id();
            $table->string('platform', 16)->default('android'); // android | ios | web
            $table->string('source_path', 191)->nullable();     // /, /download, /features …
            $table->string('link_location', 64)->nullable();    // header, hero_callout, primary_cta, footer_badge …
            $table->string('utm_source', 191)->nullable();
            $table->string('utm_medium', 191)->nullable();
            $table->string('utm_campaign', 191)->nullable();
            $table->string('utm_content', 191)->nullable();
            $table->string('utm_term', 191)->nullable();
            $table->string('referrer', 512)->nullable();
            $table->string('country', 2)->nullable();
            $table->string('ip_hash', 64)->nullable();          // sha256(ip + app key) — no raw IP stored
            $table->string('user_agent', 512)->nullable();
            $table->string('click_id', 40)->nullable();

            $table->timestamp('created_at')->nullable();

            $table->index('created_at');
            $table->index(['platform', 'created_at']);
            $table->index('utm_source');
            $table->index('click_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('store_link_clicks');
    }
};
