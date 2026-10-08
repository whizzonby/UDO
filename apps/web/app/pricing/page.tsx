import type { Metadata } from 'next';
import Link from 'next/link';
import { Check } from 'lucide-react';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { Shell, PageHeader, Display, Eyebrow, Reveal } from '@/components/landing/editorial/Shell';
import { Faq } from '@/components/landing/editorial/Faq';
import { color, container } from '@/components/landing/editorial/tokens';

export const metadata: Metadata = {
  title: 'Pricing | Udo Wedding Planner',
  description:
    'Plan your wedding free with up to 30 guests, then unlock everything with Udo Premium at $4.99/month or a one-time $49.99 Wedding Pass.',
  alternates: { canonical: '/pricing' },
};

/** Everything both paid plans unlock — they differ only in how you pay. */
const PAID_INCLUDES = [
  'Unlimited guests, vendors and messaging',
  'Invite your partner, planner and helpers',
  'Seating planner',
  'Budget tracking with payment schedules',
  'Wedding timeline',
  'Announcements and reminders',
  'Photo sharing and gallery',
  'Privacy controls and navigation tools',
] as const;

/** Limits come from the API's plan definitions (SubscriptionEntitlementService). */
const COMPARE: [string, string, string][] = [
  ['Guests', 'Up to 30', 'Unlimited'],
  ['Team members', 'Just you', 'Partner, planner and helpers'],
  ['Vendors', '3', 'Unlimited'],
  ['Invitations sent', '5', 'Unlimited'],
  ['Messages to guests', '100 a month', 'Unlimited'],
  ['Gallery photos', '20', 'Unlimited'],
  ['AI assistant questions', '5 a month', 'Unlimited'],
  ['Weddings', '1', 'Unlimited'],
];

const PRICING_FAQ = [
  {
    q: 'What’s the difference between Udo Premium and the Wedding Pass?',
    a: 'Nothing in what you can do: both unlock everything. Udo Premium is a monthly subscription you can cancel at any time. The Wedding Pass is a single payment that never renews.',
  },
  {
    q: 'Is the free plan really free?',
    a: 'Yes. Create your account and start planning with up to 30 guests at no cost. Upgrade only if and when you need more.',
  },
  {
    q: 'Can my partner or planner plan with me?',
    a: 'On the free plan the wedding is just yours. Udo Premium and the Wedding Pass let you invite your partner, a planner and other helpers, each with the right permissions.',
  },
  {
    q: 'How do I cancel Udo Premium?',
    a: 'You can cancel at any time. If you subscribed in the app, manage it from your Google Play or App Store subscriptions.',
  },
  {
    q: 'Which currency are the prices in?',
    a: 'Prices on this page are in US dollars. In the app, Google Play and the App Store show the price in your local currency.',
  },
] as const;

export default function PricingPage() {
  return (
    <Shell>
      <PageHeader
        eyebrow="Pricing"
        title={
          <>
            Start free.
            <br />
            Upgrade when it gets real.
          </>
        }
        intro="Plan your wedding free with a small guest list. When you’re ready, unlock everything with a monthly subscription or a single payment. Same features either way."
      />

      {/* Plans — a quiet free column beside one block holding both paid options */}
      <section aria-label="Plans" className="pb-20 sm:pb-28" style={{ backgroundColor: color.ivory }}>
        <div className={`${container} grid gap-8 lg:grid-cols-12 lg:gap-10`}>
          <Reveal className="border-t-2 border-[#C9BBA8] pt-8 lg:col-span-4">
            <h2 className="font-display text-[34px] font-medium" style={{ color: color.forest }}>
              Free
            </h2>
            <p className="mt-2 text-[16px]" style={{ color: color.body }}>
              For getting started with a small guest list.
            </p>
            <p className="font-display mt-8 text-[64px] font-medium leading-none" style={{ color: color.forest }}>
              $0
            </p>
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              data-store-link="pricing-free-play"
              className="mt-8 inline-flex min-h-[52px] w-full items-center justify-center rounded-md border text-[15px] font-semibold transition-transform duration-300 hover:-translate-y-0.5 lg:mt-[68px] xl:mt-[53px]"
              style={{ borderColor: color.forest, color: color.forest }}
            >
              Start free
            </a>
            {/* Desktop offset lines the first item up with the paid "Both include" list. */}
            <ul className="mt-8 space-y-3 lg:mt-[140px] xl:mt-[139px]">
              {['Up to 30 guests', 'Guest portal and RSVPs', 'Task checklist and vision board', 'Basic budget tracking', 'Up to 3 vendors'].map((t) => (
                <li key={t} className="flex gap-3 text-[16px]" style={{ color: color.charcoal }}>
                  <Check size={18} className="mt-1 shrink-0" style={{ color: color.roseDeep }} aria-hidden="true" />
                  {t}
                </li>
              ))}
            </ul>
          </Reveal>

          <Reveal delay={0.1} className="lg:col-span-8">
            <div className="h-full rounded-sm px-5 py-8 sm:px-8 sm:py-10" style={{ backgroundColor: color.forest }}>
              {/* Two separate panels, equal height, buttons aligned at the bottom */}
              <div className="grid gap-5 sm:grid-cols-2">
                <PaidPlan
                  name="Udo Premium"
                  price="$4.99"
                  cadence="per month"
                  note="Cancel anytime."
                  href="/checkout?plan=premium"
                  cta="Choose Premium"
                />
                <PaidPlan
                  name="Wedding Pass"
                  price="$49.99"
                  cadence="one time"
                  note="One payment. Never renews."
                  href="/checkout?plan=pass"
                  cta="Get the Wedding Pass"
                  label="Best value"
                  emphasis
                />
              </div>
              <div className="mt-10 border-t pt-8" style={{ borderColor: color.lineOnForest }}>
                <p className="text-[12px] font-semibold uppercase tracking-[0.2em]" style={{ color: color.champagne }}>
                  Both include everything
                </p>
                <ul className="mt-5 grid gap-x-8 gap-y-3 sm:grid-cols-2">
                  {PAID_INCLUDES.map((t) => (
                    <li key={t} className="flex gap-3 text-[15.5px]" style={{ color: color.ivory }}>
                      <Check size={18} className="mt-0.5 shrink-0" style={{ color: color.champagne }} aria-hidden="true" />
                      {t}
                    </li>
                  ))}
                </ul>
                <p className="mt-8 text-[14px] leading-relaxed" style={{ color: color.blush }}>
                  You can also upgrade from inside the app, where Google Play shows the price in your local currency.
                </p>
              </div>
            </div>
          </Reveal>
        </div>
      </section>

      {/* Comparison — a plain, honest ledger */}
      <section aria-labelledby="compare-title" className="py-20 sm:py-28" style={{ backgroundColor: color.cream }}>
        <div className={`${container} grid gap-12 lg:grid-cols-12`}>
          <Reveal className="lg:col-span-4">
            <Eyebrow>Compare</Eyebrow>
            <Display id="compare-title" className="t-h3">
              What changes when you upgrade.
            </Display>
          </Reveal>
          <Reveal delay={0.1} className="lg:col-span-8">
            <table className="w-full border-collapse text-left">
              <caption className="sr-only">Free plan compared with Udo Premium and the Wedding Pass</caption>
              <thead>
                <tr className="border-b-2 border-[#C9BBA8]">
                  <th scope="col" className="py-4 pr-4 text-[13px] font-semibold uppercase tracking-[0.14em]" style={{ color: color.champagneDeep }}>
                    <span className="sr-only">Feature</span>
                  </th>
                  <th scope="col" className="py-4 pr-4 text-[15px] font-semibold" style={{ color: color.forest }}>
                    Free
                  </th>
                  <th scope="col" className="py-4 text-[15px] font-semibold" style={{ color: color.forest }}>
                    Premium &amp; Wedding Pass
                  </th>
                </tr>
              </thead>
              <tbody>
                {COMPARE.map(([feature, free, paid]) => (
                  <tr key={feature} className="border-b border-[#D8CFC2]">
                    <th scope="row" className="py-4 pr-4 text-[15.5px] font-medium" style={{ color: color.charcoal }}>
                      {feature}
                    </th>
                    <td className="py-4 pr-4 text-[15.5px]" style={{ color: color.body }}>
                      {free}
                    </td>
                    <td className="py-4 text-[15.5px] font-medium" style={{ color: color.forest }}>
                      {paid}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </Reveal>
        </div>
      </section>

      <Faq id="pricing-faq" items={PRICING_FAQ} title="Questions about pricing." />
    </Shell>
  );
}

function PaidPlan({
  name,
  price,
  cadence,
  note,
  href,
  cta,
  label,
  emphasis = false,
}: {
  name: string;
  price: string;
  cadence: string;
  note: string;
  href: string;
  cta: string;
  label?: string;
  emphasis?: boolean;
}) {
  return (
    <div
      className="flex h-full flex-col rounded-md border px-6 py-7"
      style={{ borderColor: emphasis ? color.champagne : color.lineOnForest }}
    >
      <div className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
        <h2 className="whitespace-nowrap font-display text-[30px] font-medium" style={{ color: color.ivory }}>
          {name}
        </h2>
        {label && (
          <span className="text-[12px] font-semibold uppercase tracking-[0.18em]" style={{ color: color.champagne }}>
            {label}
          </span>
        )}
      </div>
      <p className="mt-6 flex items-baseline gap-3">
        <span className="font-display text-[60px] font-medium leading-none" style={{ color: color.ivory }}>
          {price}
        </span>
        <span className="text-[15px]" style={{ color: color.blush }}>
          {cadence}
        </span>
      </p>
      <p className="mt-3 text-[15.5px]" style={{ color: color.blush }}>
        {note}
      </p>
      {/* Spacer keeps both buttons on the same line even if one note wraps. */}
      <div className="min-h-8 flex-1" aria-hidden="true" />
      <Link
        href={href}
        className="inline-flex min-h-[52px] w-full items-center justify-center rounded-md text-[15px] font-semibold transition-transform duration-300 hover:-translate-y-0.5"
        style={
          emphasis
            ? { backgroundColor: color.ivory, color: color.forest }
            : { border: `1px solid ${color.ivory}`, color: color.ivory }
        }
      >
        {cta}
      </Link>
    </div>
  );
}
