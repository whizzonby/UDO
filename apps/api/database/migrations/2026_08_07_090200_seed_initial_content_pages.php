<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $now = now();

        DB::table('content_pages')->insert([
            [
                'slug' => 'privacy-policy',
                'title' => 'Privacy Policy',
                'body' => <<<'TEXT'
                    DRAFT — this page has not been reviewed by legal counsel yet. Replace this text with your finalised policy before relying on it.

                    Udo ("we", "us") helps couples and their guests plan and run a wedding. This page explains what we collect and how we use it.

                    What we collect
                    Account details you provide (name, email, phone), wedding planning data you enter (guest lists, budgets, vendors, timelines), and content you upload (photos, messages). We also collect basic usage data to keep the app reliable.

                    How we use it
                    To run the features you use — guest management, RSVPs, budgeting, messaging and the guest-facing wedding portal — and to communicate with you about your account.

                    Sharing
                    We share data with the vendors you explicitly connect (e.g. payment processors for billing) and never sell your data to third parties.

                    Your choices
                    You can export or delete your account data from Settings at any time.

                    Contact
                    Questions about this policy can be sent to hello@whizzonby.com.
                    TEXT,
            ],
            [
                'slug' => 'terms-of-service',
                'title' => 'Terms of Service',
                'body' => <<<'TEXT'
                    DRAFT — this page has not been reviewed by legal counsel yet. Replace this text with your finalised terms before relying on it.

                    These terms govern your use of Udo. By creating an account you agree to them.

                    Your account
                    You're responsible for the accuracy of the information you enter and for keeping your login credentials secure.

                    Subscriptions
                    Some features require a paid plan. Plans, pricing and billing cycles are shown at checkout and can be changed from Settings > Subscription.

                    Acceptable use
                    Don't use Udo to send unlawful, abusive or unsolicited content to guests or other users.

                    Availability
                    We aim to keep Udo available at all times but don't guarantee uninterrupted service.

                    Changes
                    We may update these terms as the product evolves; material changes will be announced in-app.

                    Contact
                    Questions about these terms can be sent to hello@whizzonby.com.
                    TEXT,
            ],
            [
                'slug' => 'company-information',
                'title' => 'Company Information',
                'body' => <<<'TEXT'
                    DRAFT — replace with your real registered business details.

                    Udo is a wedding planning platform that helps couples manage guests, budget, logistics and the day-of experience, and gives guests a shared portal for RSVPs and updates.

                    Registered business name: [add legal entity name]
                    Registered address: [add registered address]
                    Company/registration number: [add number if applicable]

                    Support: hello@whizzonby.com
                    TEXT,
            ],
        ]);
    }

    public function down(): void
    {
        DB::table('content_pages')->whereIn('slug', ['privacy-policy', 'terms-of-service', 'company-information'])->delete();
    }
};
