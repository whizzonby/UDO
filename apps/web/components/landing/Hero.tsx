import Link from 'next/link';
import { Calendar, Users, Link2 } from 'lucide-react';
import { C, GooglePlayCallout, IconChip, PlayStoreButton, GhostButton } from './shared';

const bullets = [
  { icon: Calendar, label: 'Know what to do next' },
  { icon: null, label: 'Keep everything in one place' },
  { icon: Users, label: 'Stay in control of guests' },
  { icon: Link2, label: 'Share one beautiful guest link' },
];

export function Hero() {
  return (
    <section
      className="flex flex-col overflow-hidden px-6 lg:px-8"
      style={{ backgroundColor: C.cream, minHeight: 'calc(100svh - 68px)' }}
    >
      <div className="mx-auto flex w-full max-w-2xl flex-1 flex-col justify-center py-8">
        <GooglePlayCallout className="self-start" />

        <h1
          className="mt-7 text-[38px] leading-[1.04] tracking-tight sm:text-[52px] lg:text-[58px]"
          style={{ color: C.ink, fontWeight: 700 }}
        >
          Plan your wedding.
          <br />
          <span style={{ color: C.rose }}>Keep your peace.</span>
        </h1>

        <p className="mt-4 text-[16px] leading-[1.6] sm:text-[17px]" style={{ color: C.bodyMuted }}>
          A calm, intelligent wedding planning space for couples and planners.
        </p>
        <p className="mt-3 text-[16px] leading-[1.65] sm:text-[17px]" style={{ color: C.body }}>
          Udo brings your guests, timeline, seating, budget, reminders, and wedding details
          into one beautifully organized place.
        </p>

        <ul className="mt-6 space-y-3">
          {bullets.map(({ icon: Icon, label }) => (
            <li key={label} className="flex items-center gap-3">
              <IconChip size="sm">
                {Icon ? (
                  <Icon className="h-4 w-4" style={{ color: C.rose }} />
                ) : (
                  <span className="h-3.5 w-3.5 rounded-full" style={{ backgroundColor: C.rose }} />
                )}
              </IconChip>
              <span className="text-[15px]" style={{ color: C.body, fontWeight: 450 }}>
                {label}
              </span>
            </li>
          ))}
        </ul>

        <div className="mt-7 flex flex-col gap-3 sm:flex-row">
          <PlayStoreButton block />
          <GhostButton href="/how-it-works" block>
            See how it works
          </GhostButton>
        </div>
      </div>

      <div className="mx-auto flex w-full max-w-2xl items-center justify-center gap-5 pb-5 text-[13px]" style={{ color: C.bodyMuted }}>
        <Link href="/privacy" className="hover:opacity-70">Privacy</Link>
        <Link href="/terms" className="hover:opacity-70">Terms</Link>
        <span>iOS coming soon</span>
      </div>
    </section>
  );
}
