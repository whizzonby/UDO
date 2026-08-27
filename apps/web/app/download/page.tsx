import Link from 'next/link';
import { PLAY_STORE_URL } from '@/lib/appLinks';

export const metadata = {
  title: 'Get the Udo App | Udo Weddings',
  description:
    'Download Udo — a calm, intelligent wedding planning space for couples and planners. Guests, timeline, seating, budget, and reminders in one place.',
  alternates: { canonical: '/download' },
  openGraph: {
    title: 'Get the Udo App',
    description:
      'Plan your wedding. Keep your peace. Download Udo free on Google Play.',
    url: '/download',
    type: 'website',
  },
};

const features = [
  'Track RSVPs and manage your full guest list',
  'Seating planner, budget, and payment schedules',
  'A shared timeline so you always know what’s next',
  'One elegant guest link for everything they need',
];

export default function DownloadPage() {
  return (
    <main className="flex min-h-screen flex-col bg-[#fbf7f4] px-6 py-14 text-[#2d2729]">
      <div className="mx-auto flex w-full max-w-md flex-1 flex-col items-center text-center">
        {/* Wordmark */}
        <Link href="/" className="flex items-center gap-3">
          <span
            className="flex h-11 w-11 items-center justify-center rounded-full"
            style={{ background: 'linear-gradient(135deg, #E8A0A8 0%, #D8909A 100%)' }}
          >
            <span className="text-lg font-semibold text-white" style={{ fontFamily: 'var(--font-heading), Georgia, serif' }}>
              U
            </span>
          </span>
          <span className="font-serif text-2xl tracking-wide">Udo</span>
        </Link>

        <h1 className="mt-12 font-serif text-4xl leading-tight sm:text-5xl">
          Plan your wedding.
          <br />
          <span className="text-[#D8909A]">Keep your peace.</span>
        </h1>

        <p className="mt-5 text-[15px] leading-7 text-[#4f4648]">
          Udo brings your guests, timeline, seating, budget, reminders, and wedding
          details into one beautifully organized place.
        </p>

        {/* Google Play */}
        <a
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Get it on Google Play"
          className="mt-9 inline-flex items-center gap-3 rounded-2xl bg-black px-7 py-4 text-white transition-opacity hover:opacity-85"
        >
          <svg width="24" height="26" viewBox="0 0 22 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <path d="M0.43 0.22C0.16 0.51 0 0.96 0 1.54v20.92c0 .58.16 1.03.44 1.32l.07.07 11.72-11.72v-.28L0.5.15.43.22z" fill="#00E3FF" />
            <path d="M16.07 15.97l-3.9-3.9v-.28l3.9-3.9.09.05 4.62 2.62c1.32.75 1.32 1.98 0 2.73l-4.62 2.62-.09.06z" fill="#FFC800" />
            <path d="M16.16 15.91L12.17 12 .43 23.74c.43.46 1.15.52 1.96.06l13.77-7.89" fill="#FF3A44" />
            <path d="M16.16 8.09L2.39.2C1.58-.26.86-.2.43.26L12.17 12l4-3.91z" fill="#32A071" />
          </svg>
          <span className="flex flex-col items-start leading-none">
            <span className="text-[11px] font-normal">GET IT ON</span>
            <span className="text-[19px] font-semibold" style={{ letterSpacing: '-0.3px' }}>
              Google Play
            </span>
          </span>
        </a>

        <p className="mt-4 text-xs text-[#9b6a75]">iOS app coming soon</p>

        {/* Features */}
        <ul className="mt-12 w-full space-y-3 text-left">
          {features.map((feature) => (
            <li key={feature} className="flex items-start gap-3 text-sm leading-6 text-[#4f4648]">
              <span
                className="mt-1.5 h-1.5 w-1.5 flex-shrink-0 rounded-full"
                style={{ backgroundColor: '#D8909A' }}
              />
              {feature}
            </li>
          ))}
        </ul>
      </div>

      <footer className="mx-auto mt-14 flex w-full max-w-md items-center justify-center gap-6 text-xs text-[#9b6a75]">
        <Link href="/" className="hover:opacity-70">Home</Link>
        <Link href="/privacy" className="hover:opacity-70">Privacy</Link>
        <Link href="/terms" className="hover:opacity-70">Terms</Link>
      </footer>
    </main>
  );
}
