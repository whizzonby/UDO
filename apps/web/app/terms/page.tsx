import Link from 'next/link';

export const metadata = {
  title: 'Terms of Service | Udo Weddings',
};

export default function TermsOfServicePage() {
  return (
    <main className="min-h-screen bg-[#fbf7f4] px-6 py-16 text-[#2d2729]">
      <div className="mx-auto max-w-2xl">
        <Link href="/" className="text-sm text-[#8c5367]">&larr; Back</Link>
        <h1 className="mt-6 font-serif text-4xl">Terms of Service</h1>
        <p className="mt-2 text-xs uppercase tracking-wider text-[#9b6a75]">
          Draft — this page has not been reviewed by legal counsel yet.
        </p>

        <div className="mt-8 space-y-6 text-sm leading-7 text-[#4f4648]">
          <p>These terms govern your use of Udo. By creating an account you agree to them.</p>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Your account</h2>
            <p className="mt-2">
              You&apos;re responsible for the accuracy of the information you enter and for keeping
              your login credentials secure.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Subscriptions</h2>
            <p className="mt-2">
              Some features require a paid plan. Plans, pricing and billing cycles are shown at
              checkout and can be changed from Settings &gt; Subscription.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Acceptable use</h2>
            <p className="mt-2">
              Don&apos;t use Udo to send unlawful, abusive or unsolicited content to guests or other
              users.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Availability</h2>
            <p className="mt-2">
              We aim to keep Udo available at all times but don&apos;t guarantee uninterrupted
              service.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Changes</h2>
            <p className="mt-2">
              We may update these terms as the product evolves; material changes will be announced
              in-app.
            </p>
          </section>
          <section>
            <h2 className="font-serif text-xl text-[#2d2729]">Contact</h2>
            <p className="mt-2">
              Questions about these terms can be sent to{' '}
              <a href="mailto:hello@whizzonby.com" className="text-[#8c5367] underline">hello@whizzonby.com</a>.
            </p>
          </section>
        </div>
      </div>
    </main>
  );
}
