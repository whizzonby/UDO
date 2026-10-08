import { Shell } from '@/components/landing/editorial/Shell';

export const metadata = {
  title: 'Terms of Service | Udo Weddings',
};

export default function TermsOfServicePage() {
  return (
    <Shell finalCta={false}>
    <article className="px-5 pb-24 pt-[calc(68px+3.5rem)] text-[#252925] sm:px-8" style={{ backgroundColor: '#F8F6F1' }}>
      <div className="mx-auto max-w-2xl">
        <h1 className="font-display text-[clamp(2.6rem,2rem+2.4vw,3.8rem)] font-medium leading-[1.05] text-[#243B35]">Terms of Service</h1>
        <p className="mt-2 text-xs uppercase tracking-wider text-[#94586A]">
          Draft — this page has not been reviewed by legal counsel yet.
        </p>

        <div className="mt-8 space-y-6 text-[16px] leading-[1.75] text-[#4A4F49]">
          <p>These terms govern your use of Udo. By creating an account you agree to them.</p>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Your account</h2>
            <p className="mt-2">
              You&apos;re responsible for the accuracy of the information you enter and for keeping
              your login credentials secure.
            </p>
          </section>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Subscriptions</h2>
            <p className="mt-2">
              Some features require a paid plan. Plans, pricing and billing cycles are shown at
              checkout and can be changed from Settings &gt; Subscription.
            </p>
          </section>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Acceptable use</h2>
            <p className="mt-2">
              Don&apos;t use Udo to send unlawful, abusive or unsolicited content to guests or other
              users.
            </p>
          </section>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Availability</h2>
            <p className="mt-2">
              We aim to keep Udo available at all times but don&apos;t guarantee uninterrupted
              service.
            </p>
          </section>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Changes</h2>
            <p className="mt-2">
              We may update these terms as the product evolves; material changes will be announced
              in-app.
            </p>
          </section>
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Contact</h2>
            <p className="mt-2">
              Questions about these terms can be sent to{' '}
              <a href="mailto:hello@udowedding.com" className="text-[#94586A] underline">hello@udowedding.com</a>.
            </p>
          </section>
        </div>
      </div>
    </article>
    </Shell>
  );
}
