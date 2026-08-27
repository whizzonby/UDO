import Link from 'next/link';
import { Check } from 'lucide-react';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { C, Section } from './shared';

const freeFeatures = [
  'Up to 30 guests',
  'Guest portal & RSVP',
  'Task checklist & vision board',
  'Basic budget tracking',
  '3 vendors',
];

const passFeatures = [
  'Unlimited guests, vendors & messaging',
  'Full wedding setup',
  'Seating planner',
  'Budget tracking & payment schedules',
  'Wedding timeline',
  'Announcements & reminders',
  'Photo sharing',
  'Privacy controls',
  'Navigation tools',
];

function FeatureList({ features, checkColor }: { features: string[]; checkColor: string }) {
  return (
    <ul className="mt-8 space-y-3">
      {features.map((feature) => (
        <li key={feature} className="flex items-start gap-3">
          <span
            className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full"
            style={{ backgroundColor: `${checkColor}26` }}
          >
            <Check className="h-3 w-3" style={{ color: checkColor }} />
          </span>
          <span className="text-[15px]" style={{ color: C.body }}>
            {feature}
          </span>
        </li>
      ))}
    </ul>
  );
}

export function Pricing() {
  return (
    <Section id="pricing" tone="white" width="wide">
      <div className="mx-auto grid max-w-3xl gap-6 md:grid-cols-2">
        {/* Free */}
        <div className="flex flex-col rounded-[28px] p-9" style={{ backgroundColor: C.cream, border: `1.5px solid ${C.line}` }}>
          <p className="text-[13px] uppercase tracking-wide" style={{ color: C.body, fontWeight: 600 }}>
            Free
          </p>
          <p className="mt-3 text-[52px] leading-none tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
            $0
          </p>
          <p className="mt-2 text-[14px]" style={{ color: C.body }}>
            For trying Udo with a small planning circle.
          </p>
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="mt-6 flex w-full items-center justify-center rounded-full py-3.5 text-[15px] font-medium transition-colors hover:bg-[#EBD9CE]"
            style={{ border: `1.5px solid ${C.rose}`, color: C.rose }}
          >
            Start Free
          </a>
          <FeatureList features={freeFeatures} checkColor={C.rose} />
        </div>

        {/* Wedding Pass */}
        <div className="relative flex flex-col overflow-hidden rounded-[28px] p-9" style={{ backgroundColor: C.tan }}>
          <span
            className="absolute right-6 top-6 rounded-full px-3 py-1 text-[11px] font-medium text-white"
            style={{ backgroundColor: C.rose }}
          >
            Most popular
          </span>
          <p className="text-[13px] uppercase tracking-wide" style={{ color: C.body, fontWeight: 600 }}>
            Wedding Pass
          </p>
          <p className="mt-3 text-[52px] leading-none tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
            $45
          </p>
          <p className="mt-2 text-[14px]" style={{ color: C.body }}>
            One-time payment. No subscriptions, ever.
          </p>
          <Link
            href="/checkout"
            className="mt-6 flex w-full items-center justify-center rounded-full py-3.5 text-[15px] font-medium text-white shadow-md transition-all hover:opacity-95 hover:shadow-lg"
            style={{ backgroundColor: C.rose }}
          >
            Get Wedding Pass
          </Link>
          <FeatureList features={passFeatures} checkColor={C.taupe} />
        </div>
      </div>

      <div className="mt-8 flex flex-wrap items-center justify-center gap-x-8 gap-y-2 text-[14px]" style={{ color: C.bodyMuted }}>
        <span className="flex items-center gap-2"><Check className="h-4 w-4" style={{ color: C.roseSoft }} /> No monthly fees</span>
        <span className="flex items-center gap-2"><Check className="h-4 w-4" style={{ color: C.roseSoft }} /> No card to start</span>
        <span className="flex items-center gap-2"><Check className="h-4 w-4" style={{ color: C.roseSoft }} /> Upgrade any time</span>
      </div>
    </Section>
  );
}
