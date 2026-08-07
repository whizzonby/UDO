import Link from 'next/link';

export const metadata = {
  title: 'Privacy Policy | Udo Weddings',
};

export default function PrivacyPolicyPage() {
  return (
    <main className="min-h-screen bg-[#fbf7f4] px-6 py-16 text-[#2d2729]">
      <div className="mx-auto max-w-2xl">
        <Link href="/" className="text-sm text-[#8c5367]">&larr; Back</Link>
        <h1 className="mt-6 font-serif text-4xl">Privacy Policy</h1>
        <p className="mt-2 text-xs uppercase tracking-wider text-[#9b6a75]">
          Draft — this page has not been reviewed by legal counsel yet.
        </p>

        <div className="mt-8 space-y-6 text-sm leading-7 text-[#4f4648]">
          <p>
            Udo (&ldquo;we&rdquo;, &ldquo;us&rdquo;) helps couples and their guests plan and run a wedding.
            This page explains what we collect and how we use it.
          </p>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">What we collect</h2>
            <p className="mt-2">
              Account details you provide (name, email, phone), wedding planning data you enter
              (guest lists, budgets, vendors, timelines), and content you upload (photos, messages).
              We also collect basic usage data to keep the app reliable.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">How we use it</h2>
            <p className="mt-2">
              To run the features you use — guest management, RSVPs, budgeting, messaging and the
              guest-facing wedding portal — and to communicate with you about your account.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Sharing</h2>
            <p className="mt-2">
              We share data with the vendors you explicitly connect (e.g. payment processors for
              billing) and never sell your data to third parties.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Your choices</h2>
            <p className="mt-2">You can export or delete your account data from Settings at any time.</p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Contact</h2>
            <p className="mt-2">
              Questions about this policy can be sent to{' '}
              <a href="mailto:hello@whizzonby.com" className="text-[#8c5367] underline">hello@whizzonby.com</a>.
            </p>
          </section>
        </div>
      </div>
    </main>
  );
}
