import { Calendar, Users, Link2 } from 'lucide-react';
import {
  C,
  GooglePlayCallout,
  IconChip,
  PlayStoreButton,
  GhostButton,
} from './shared';

const bullets = [
  { icon: Calendar, label: 'Know what to do next' },
  { icon: null, label: 'Keep everything in one place' },
  { icon: Users, label: 'Stay in control of guests' },
  { icon: Link2, label: 'Share one beautiful guest link' },
];

export function Hero() {
  return (
    <section className="overflow-hidden px-6 pb-16 pt-9 sm:pb-20 sm:pt-12 lg:px-8" style={{ backgroundColor: C.cream }}>
      <div className="mx-auto flex w-full max-w-2xl flex-col">
        <GooglePlayCallout className="self-start" />

        <h1
          className="mt-8 text-[40px] leading-[1.04] tracking-tight sm:text-[54px] lg:text-[60px]"
          style={{ color: C.ink, fontWeight: 700 }}
        >
          Plan your wedding.
          <br />
          <span style={{ color: C.rose }}>Keep your peace.</span>
        </h1>

        <p className="mt-5 text-[16px] leading-[1.6] sm:text-[17px]" style={{ color: C.bodyMuted }}>
          A calm, intelligent wedding planning space for couples and planners.
        </p>
        <p className="mt-4 text-[16px] leading-[1.7] sm:text-[17px]" style={{ color: C.body }}>
          Udo brings your guests, timeline, seating, budget, reminders, and wedding details
          into one beautifully organized place.
        </p>

        <ul className="mt-8 space-y-3.5">
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

        <div className="mt-8 flex flex-col gap-3 sm:flex-row">
          <PlayStoreButton block />
          <GhostButton href="#how-it-works" block>
            See How It Works
          </GhostButton>
        </div>
      </div>
    </section>
  );
}
