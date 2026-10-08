import type { Metadata } from 'next';
import { Check } from 'lucide-react';
import heroAisle from '@/public/landing/hero-aisle.jpg';
import appHome from '@/public/landing/app-home.jpg';
import { Shell, Display } from '@/components/landing/editorial/Shell';
import { Phone, Photo, StoreButtons } from '@/components/landing/editorial/Primitives';
import { color, container } from '@/components/landing/editorial/tokens';

export const metadata: Metadata = {
  title: 'Get the Udo App | Udo Wedding Planner',
  description:
    'Download Udo on Google Play: a calm wedding planning app for couples and planners. Guests and RSVPs, timeline, seating, budget and reminders in one place.',
  alternates: { canonical: '/download' },
  openGraph: {
    title: 'Get the Udo App',
    description: 'Plan your wedding. Keep your peace. Download Udo free on Google Play.',
    url: '/download',
    type: 'website',
    images: [{ url: '/landing/og.jpg', width: 1200, height: 630 }],
  },
};

const POINTS = [
  'Know what to do next, every day',
  'Guests, budget, timeline and seating in one place',
  'One personal link per guest, no app needed for them',
  'Free to start with up to 30 guests',
] as const;

/**
 * Ad landing page: one focused screen that gets the visitor to the store.
 * Same menu and footer as the rest of the site, but no long story.
 */
export default function DownloadPage() {
  return (
    <Shell finalCta={false}>
      <section aria-labelledby="download-title" className="pt-[68px]" style={{ backgroundColor: color.ivory }}>
        <div className={`${container} grid items-center gap-12 pb-16 pt-10 lg:min-h-[min(calc(100svh-68px),860px)] lg:grid-cols-12 lg:gap-8 lg:pb-16`}>
          <div className="lg:col-span-6">
            <p className="rise mb-6 flex items-center gap-3 text-[12px] font-semibold uppercase tracking-[0.24em]" style={{ color: color.champagneDeep }}>
              <span className="h-px w-8" style={{ backgroundColor: color.rose }} aria-hidden="true" />
              Get the app
            </p>
            <Display as="h1" id="download-title" className="t-hero rise rise-1">
              Plan your wedding.
              <br />
              <span style={{ color: color.roseDeep }}>Keep your peace.</span>
            </Display>
            <ul className="rise rise-2 mt-8 space-y-3">
              {POINTS.map((t) => (
                <li key={t} className="flex gap-3 text-[17px]" style={{ color: color.charcoal }}>
                  <Check size={20} className="mt-0.5 shrink-0" style={{ color: color.roseDeep }} aria-hidden="true" />
                  {t}
                </li>
              ))}
            </ul>
            <div className="rise rise-3 mt-10">
              <StoreButtons placement="download" />
            </div>
          </div>

          <div className="relative lg:col-span-6">
            <div className="rise rise-1 relative ml-auto w-[80%] sm:w-[70%] lg:w-[86%]">
              <Photo
                src={heroAisle}
                alt="An outdoor wedding aisle lined with blush rose arrangements leading to a white floral arch"
                sizes="(min-width: 1024px) 45vw, 80vw"
                priority
                position="50% 40%"
                className="aspect-[4/5] rounded-t-[999px]"
              />
            </div>
            <div className="rise rise-3 absolute bottom-[-6%] left-0 w-[42%] max-w-[240px] lg:bottom-[6%] lg:left-[2%] lg:w-[38%]">
              <Phone
                src={appHome}
                alt="The Udo app home screen with a wedding countdown and today's planning focus"
                priority
                sizes="(min-width: 1024px) 240px, 42vw"
              />
            </div>
          </div>
        </div>
      </section>
    </Shell>
  );
}
