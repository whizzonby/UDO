import Link from 'next/link';
import { Shell } from '@/components/landing/editorial/Shell';

export const metadata = {
  title: 'Delete Your Account | Udo Weddings',
};

const SUPPORT_EMAIL = 'hello@udowedding.com';

export default function DeleteAccountPage() {
  return (
    <Shell finalCta={false}>
    <article className="px-5 pb-24 pt-[calc(68px+3.5rem)] text-[#252925] sm:px-8" style={{ backgroundColor: '#F8F6F1' }}>
      <div className="mx-auto max-w-2xl">
        <h1 className="font-display text-[clamp(2.6rem,2rem+2.4vw,3.8rem)] font-medium leading-[1.05] text-[#243B35]">Delete Your Account</h1>
        <p className="mt-4 text-[16px] leading-[1.75] text-[#4A4F49]">
          You can permanently delete your Udo account and all associated data at any time, either
          directly in the app or by contacting us. This removes your account, your wedding
          workspace (if you&rsquo;re the owner), and any guest records, photos, messages, and other
          content tied to it.
        </p>

        <div className="mt-8 space-y-8 text-[16px] leading-[1.75] text-[#4A4F49]">
          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">Option 1: Delete in the app</h2>
            <p className="mt-2">The fastest way, if you still have Udo installed:</p>
            <ol className="mt-2 list-decimal space-y-1.5 pl-5">
              <li>Open the Udo app and go to <strong>More</strong>.</li>
              <li>Tap <strong>Privacy &amp; Security</strong>, then <strong>Delete account</strong>.</li>
              <li>Confirm your password when prompted, then confirm deletion.</li>
            </ol>
            <p className="mt-2">
              Your account and its data are deleted immediately — this cannot be undone.
            </p>
          </section>

          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">
              Option 2: Request deletion by email
            </h2>
            <p className="mt-2">
              If you no longer have the app installed, or can&rsquo;t sign in, email us at{' '}
              <a href={`mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent('Account deletion request')}`} className="text-[#94586A] underline">
                {SUPPORT_EMAIL}
              </a>{' '}
              from the email address on your account, with the subject line &ldquo;Account
              deletion request.&rdquo; Include your full name so we can verify it&rsquo;s really
              you. We&rsquo;ll confirm your identity and delete your account and associated data
              within 30 days, and let you know once it&rsquo;s done.
            </p>
          </section>

          <section>
            <h2 className="font-display text-[28px] font-medium text-[#243B35]">What gets deleted</h2>
            <p className="mt-2">Deleting your account removes:</p>
            <ul className="mt-2 list-disc space-y-1.5 pl-5">
              <li>Your account profile (name, email, phone, password).</li>
              <li>If you&rsquo;re a wedding owner: the wedding workspace, guest list, budget,
                vendors, timeline, seating, gallery uploads, and messages tied to it.</li>
              <li>If you&rsquo;re a collaborator or guest on someone else&rsquo;s wedding: your own
                account and personal data, though information you contributed to that wedding
                (like an RSVP) may remain as part of the Planner&rsquo;s wedding record, the same
                way it would if you&rsquo;d told them by phone or in person.</li>
            </ul>
            <p className="mt-2">
              Some information may be retained longer where we&rsquo;re legally required to —
              for example, payment records kept for tax and fraud-prevention purposes — as
              described in our{' '}
              <Link href="/privacy" className="text-[#94586A] underline">Privacy Policy</Link>.
            </p>
          </section>
        </div>
      </div>
    </article>
    </Shell>
  );
}
