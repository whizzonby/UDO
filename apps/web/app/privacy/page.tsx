import Link from 'next/link';

export const metadata = {
  title: 'Privacy Policy | Udo Weddings',
};

const SUPPORT_EMAIL = 'hello@udowedding.com';
const LAST_UPDATED = 'August 12, 2026';

export default function PrivacyPolicyPage() {
  return (
    <main className="min-h-screen bg-[#fbf7f4] px-6 py-16 text-[#2d2729]">
      <div className="mx-auto max-w-2xl">
        <Link href="/" className="text-sm text-[#8c5367]">&larr; Back</Link>
        <h1 className="mt-6 font-serif text-4xl">Privacy Policy</h1>
        <p className="mt-2 text-xs uppercase tracking-wider text-[#9b6a75]">
          Last updated {LAST_UPDATED}
        </p>

        <div className="mt-8 space-y-8 text-sm leading-7 text-[#4f4648]">
          <p>
            Udo (&ldquo;Udo&rdquo;, &ldquo;we&rdquo;, &ldquo;us&rdquo;, or &ldquo;our&rdquo;) provides a wedding
            planning platform — a mobile app and website — that helps couples plan their wedding and lets their
            guests RSVP, view event details, and participate in a shared wedding portal. This Privacy Policy
            explains what information we collect, how we use and share it, and the choices you have. It applies
            to everyone who uses Udo: couples and other members of a wedding-planning team (&ldquo;Planners&rdquo;)
            and the guests they invite (&ldquo;Guests&rdquo;).
          </p>
          <p>
            By using Udo, you agree to the collection and use of information as described here. If you don&rsquo;t
            agree, please don&rsquo;t use the app or website.
          </p>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">1. Information we collect</h2>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Account information
            </h3>
            <p className="mt-2">
              When you create a Udo account, we collect your name, email address, and password (stored in
              encrypted form — we never see your plain-text password). If you sign in with Google or Apple, we
              receive your name and email from that provider instead. You may optionally add a phone number and
              profile photo.
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Wedding planning data
            </h3>
            <p className="mt-2">
              Information Planners enter to plan their wedding, including the wedding date, venue and location
              details, budget and vendor records, timelines and schedules, seating arrangements, and any notes,
              files, or photos added to the workspace.
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Guest information
            </h3>
            <p className="mt-2">
              Planners can add Guests to their wedding — typically a name, email, and/or phone number, and
              optionally details like dietary preferences, plus-one information, travel or accommodation needs,
              and RSVP status. This information is provided by the Planner, by the Guest themselves through their
              personal invite link or a shared invite code, or both. If you&rsquo;re a Guest, this means someone
              planning a wedding you&rsquo;re invited to may have added your contact details to Udo even before
              you&rsquo;ve used the app yourself — you can always contact us to have that information removed (see
              &ldquo;Your rights and choices&rdquo; below).
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Content you upload
            </h3>
            <p className="mt-2">
              Photos, videos, voice notes, and guestbook messages that Planners or Guests upload to a wedding&rsquo;s
              gallery or memory book.
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Payment information
            </h3>
            <p className="mt-2">
              If you purchase the Wedding Pass or make a registry contribution, payment is processed by Stripe,
              Google Play Billing, or Apple In-App Purchase, depending on how you pay. We receive confirmation
              that a payment was made and basic transaction details (amount, date, plan), but we never receive or
              store your full card number.
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Location and weather data
            </h3>
            <p className="mt-2">
              If a Planner adds a venue address, city, or country, we use that information to look up
              coordinates and show local weather forecasts for the wedding day and to power venue maps. We do not
              track a device&rsquo;s real-time GPS location.
            </p>

            <h3 className="mt-4 text-[13px] font-semibold uppercase tracking-wide text-[#9b6a75]">
              Usage and device data
            </h3>
            <p className="mt-2">
              Like most apps, we automatically collect some technical data to keep Udo reliable and secure —
              device type and operating system, app version, crash logs, and general usage patterns (which
              features are used, how often). We use this to fix bugs and improve the app, not to build an
              advertising profile of you.
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">2. How we use your information</h2>
            <ul className="mt-2 list-disc space-y-1.5 pl-5">
              <li>To provide and operate Udo&rsquo;s features — guest management, RSVPs, budgeting, vendor
                tracking, timelines, seating, messaging, and the guest-facing wedding portal.</li>
              <li>To send you emails, SMS, or WhatsApp messages you or a Planner has requested — RSVP
                confirmations, invitations, reminders, and account or billing notices.</li>
              <li>To process payments and prevent fraud.</li>
              <li>To power the optional &ldquo;Udo AI&rdquo; planning assistant, which uses the prompts you send it
                (and relevant wedding details needed to answer helpfully) to generate a response via OpenAI. We do
                not use your conversations to train OpenAI&rsquo;s models.</li>
              <li>To maintain security, investigate abuse, and enforce our terms.</li>
              <li>To communicate with you about your account and, if you&rsquo;ve agreed to receive them, product
                updates.</li>
            </ul>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">3. Third-party services we use</h2>
            <p className="mt-2">
              We work with the following categories of service providers to run Udo. Each only receives the
              information it needs to perform its function, and none are permitted to use your data for their own
              purposes.
            </p>
            <ul className="mt-2 list-disc space-y-1.5 pl-5">
              <li><strong>Payments:</strong> Stripe, Google Play Billing, Apple In-App Purchase.</li>
              <li><strong>Messaging:</strong> Twilio (SMS and WhatsApp delivery) and our email delivery provider.</li>
              <li><strong>AI assistant:</strong> OpenAI, to generate responses in the Udo AI chat feature.</li>
              <li><strong>Maps, weather &amp; location lookup:</strong> Google Places, OpenStreetMap/Nominatim,
                Open-Meteo, and OpenWeather.</li>
              <li><strong>Sign-in:</strong> Google Sign-In and Sign in with Apple, if you choose to use them
                instead of a password.</li>
              <li><strong>Vision board import:</strong> Pinterest, only if you choose to connect a Pinterest
                account to import boards.</li>
              <li><strong>Infrastructure:</strong> our cloud hosting and database providers, who store the data
                described in this policy on our behalf.</li>
            </ul>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">4. How we share information</h2>
            <p className="mt-2">
              We don&rsquo;t sell your personal information, ever. We share it only in these situations:
            </p>
            <ul className="mt-2 list-disc space-y-1.5 pl-5">
              <li>With the service providers listed above, solely to operate Udo&rsquo;s features on our behalf.</li>
              <li>Between Planners and Guests on the same wedding, and among collaborators a Planner has added to
                a wedding workspace — this is the core purpose of the app (e.g. a Guest&rsquo;s RSVP and meal choice
                is visible to the Planners running that wedding).</li>
              <li>If required by law, to comply with a valid legal request, or to protect the rights, property, or
                safety of Udo, our users, or the public.</li>
              <li>If Udo is involved in a merger, acquisition, or sale of assets, in which case we&rsquo;ll notify
                you before your information becomes subject to a different privacy policy.</li>
            </ul>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">5. Data retention</h2>
            <p className="mt-2">
              We keep wedding and account data for as long as the account is active, so Planners and Guests can
              keep using it before and after the wedding date (many couples want to keep photos and guestbook
              messages afterward). If you delete your account, we delete or anonymize your personal information
              within a reasonable period, except where we&rsquo;re required to retain it for legal, tax, or fraud-
              prevention purposes (for example, payment records).
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">6. Your rights and choices</h2>
            <ul className="mt-2 list-disc space-y-1.5 pl-5">
              <li><strong>Access and export:</strong> you can export your account data from Settings at any time.</li>
              <li><strong>Correction and deletion:</strong> you can update your account from Settings, or delete
                your account and data at any time — see{' '}
                <Link href="/delete-account" className="text-[#8c5367] underline">how to delete your account</Link>.</li>
              <li><strong>Communication preferences:</strong> Guests can opt out of email, SMS, or WhatsApp
                messages for a given wedding from their guest portal.</li>
              <li><strong>Guests without an account:</strong> if a Planner has added your details but you&rsquo;ve
                never signed up, contact us at the email below and we&rsquo;ll remove your information on request.</li>
              <li>Depending on where you live, you may have additional rights under laws like the GDPR or CCPA,
                including the right to object to or restrict certain processing. Contact us to exercise these
                rights.</li>
            </ul>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">7. Children&rsquo;s privacy</h2>
            <p className="mt-2">
              Udo is not directed at children, and we don&rsquo;t knowingly collect personal information from
              anyone under 13 (or the relevant minimum age in your region). If you believe a child has provided us
              with personal information, contact us and we&rsquo;ll delete it.
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">8. Data security</h2>
            <p className="mt-2">
              We use industry-standard measures to protect your information, including encryption in transit,
              hashed passwords, and access controls limiting who inside Udo can see your data. No method of
              transmission or storage is perfectly secure, so we can&rsquo;t guarantee absolute security, but we
              work to protect your information and respond quickly to any issue.
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">9. International users</h2>
            <p className="mt-2">
              Udo is used by couples and guests around the world. Your information may be processed and stored in
              countries other than the one you live in, including the United States, by us or our service
              providers. We take steps to ensure your information receives an adequate level of protection wherever
              it&rsquo;s processed.
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">10. Changes to this policy</h2>
            <p className="mt-2">
              We may update this policy as Udo changes. If we make a material change, we&rsquo;ll notify you by
              email or an in-app notice before it takes effect. The &ldquo;Last updated&rdquo; date above always
              reflects the current version.
            </p>
          </section>

          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Contact us</h2>
            <p className="mt-2">
              Questions about this policy, or requests to access, correct, or delete your information, can be sent
              to{' '}
              <a href={`mailto:${SUPPORT_EMAIL}`} className="text-[#8c5367] underline">{SUPPORT_EMAIL}</a>.
            </p>
          </section>
        </div>
      </div>
    </main>
  );
}
