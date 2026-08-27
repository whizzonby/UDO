import Link from 'next/link';
import { Calendar, Users, Link2 } from 'lucide-react';
import { PLAY_STORE_URL } from '@/lib/appLinks';

export const metadata = {
  title: 'Get the Udo App | Udo Weddings',
  description:
    'Download Udo on Google Play — a calm, intelligent wedding planning space for couples and planners. Guests, timeline, seating, budget, and reminders in one place.',
  alternates: { canonical: '/download' },
  openGraph: {
    title: 'Get the Udo App',
    description:
      'Plan your wedding. Keep your peace. Download Udo free on Google Play.',
    url: '/download',
    type: 'website',
  },
};

const bullets = [
  { icon: Calendar, label: 'Know what to do next' },
  { icon: null, label: 'Keep everything in one place' },
  { icon: Users, label: 'Stay in control of guests' },
  { icon: Link2, label: 'Share one beautiful guest link' },
];

function GooglePlayIcon({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 22 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <path d="M0.43 0.22C0.16 0.51 0 0.96 0 1.54v20.92c0 .58.16 1.03.44 1.32l.07.07 11.72-11.72v-.28L0.5.15.43.22z" fill="#00D2FF" />
      <path d="M16.07 15.97l-3.9-3.9v-.28l3.9-3.9.09.05 4.62 2.62c1.32.75 1.32 1.98 0 2.73l-4.62 2.62-.09.06z" fill="#FFC900" />
      <path d="M16.16 15.91L12.17 12 .43 23.74c.43.46 1.15.52 1.96.06l13.77-7.89" fill="#F9394B" />
      <path d="M16.16 8.09L2.39.2C1.58-.26.86-.2.43.26L12.17 12l4-3.91z" fill="#33C481" />
    </svg>
  );
}

export default function DownloadPage() {
  return (
    <main className="flex min-h-screen flex-col bg-[#FFF8F5] text-[#2D2D2F]">
      {/* Header */}
      <header
        className="sticky top-0 z-10 border-b backdrop-blur-md"
        style={{ backgroundColor: 'rgba(255, 248, 245, 0.95)', borderColor: 'rgba(139, 111, 92, 0.1)' }}
      >
        <div className="mx-auto flex w-full max-w-2xl items-center justify-between px-5 py-3">
          <Link href="/" className="flex items-center gap-3">
            <span
              className="flex h-10 w-10 items-center justify-center rounded-full text-lg font-semibold text-white"
              style={{ background: 'linear-gradient(135deg, #E8A0A8 0%, #D8909A 100%)' }}
            >
              U
            </span>
            <span className="text-[24px] font-medium tracking-wide">Udo</span>
          </Link>
          <div className="flex items-center gap-4">
            <Link href="/login" className="text-sm font-medium text-[#5A524D] hover:opacity-70">
              Sign in
            </Link>
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-full px-5 py-2.5 text-sm font-medium text-white transition-opacity hover:opacity-90"
              style={{ backgroundColor: '#E8A0A8' }}
            >
              Get the App
            </a>
          </div>
        </div>
      </header>

      {/* Hero — everything the visitor needs, above the fold */}
      <div className="mx-auto flex w-full max-w-2xl flex-1 flex-col px-5 pb-8 pt-7">
        {/* Google Play callout */}
        <a
          href={PLAY_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Download on the Google Play Store"
          className="relative self-start transition-transform hover:-translate-y-0.5"
        >
          <span
            className="flex items-center gap-3.5 rounded-2xl border px-5 py-3"
            style={{ borderColor: '#EAC7BF', backgroundColor: 'rgba(255,255,255,0.4)' }}
          >
            <GooglePlayIcon className="h-7 w-7 shrink-0" />
            <span className="flex flex-col leading-tight" style={{ color: '#D8909A' }}>
              <span className="text-[11px] font-bold tracking-[0.16em]">DOWNLOAD TODAY</span>
              <span className="text-[15px] font-bold tracking-[0.02em]">ON THE GOOGLE PLAY STORE</span>
            </span>
          </span>
          {/* sparkle doodle */}
          <svg
            className="absolute -left-2.5 -top-3.5 h-5 w-5"
            viewBox="0 0 24 24"
            fill="none"
            stroke="#E8A0A8"
            strokeWidth="2"
            strokeLinecap="round"
            aria-hidden="true"
          >
            <path d="M12 3v5M5.5 6.5l3 3M18.5 6.5l-3 3" />
          </svg>
          {/* curly arrow doodle pointing toward the button */}
          <svg
            className="absolute -right-8 top-1/2 hidden h-12 w-10 -translate-y-1/2 sm:block"
            viewBox="0 0 40 48"
            fill="none"
            stroke="#E8A0A8"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden="true"
          >
            <path d="M6 6c14 1 22 12 18 30" />
            <path d="M17 32l7 6 5-8" />
          </svg>
        </a>

        <h1 className="mt-7 text-[40px] font-bold leading-[1.05] tracking-tight sm:text-[56px]">
          Plan your wedding.
          <br />
          <span style={{ color: '#D8909A' }}>Keep your peace.</span>
        </h1>

        <p className="mt-5 text-[16px] leading-relaxed" style={{ color: '#6B625C' }}>
          A calm, intelligent wedding planning space for couples and planners.
        </p>
        <p className="mt-4 text-[16px] leading-relaxed" style={{ color: '#5A524D' }}>
          Udo brings your guests, timeline, seating, budget, reminders, and wedding details
          into one beautifully organized place.
        </p>

        <ul className="mt-7 space-y-3.5">
          {bullets.map(({ icon: Icon, label }) => (
            <li key={label} className="flex items-center gap-3">
              <span
                className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full"
                style={{ backgroundColor: '#EBD9CE' }}
              >
                {Icon ? (
                  <Icon className="h-4 w-4" style={{ color: '#D8909A' }} />
                ) : (
                  <span className="h-3.5 w-3.5 rounded-full" style={{ backgroundColor: '#D8909A' }} />
                )}
              </span>
              <span className="text-[15px]" style={{ color: '#5A524D', fontWeight: 450 }}>
                {label}
              </span>
            </li>
          ))}
        </ul>

        <div className="mt-8 flex flex-col gap-3">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="flex w-full items-center justify-center rounded-full px-8 py-4 text-base font-medium text-white shadow-md transition-all hover:shadow-lg hover:opacity-95"
            style={{ backgroundColor: '#D8909A', letterSpacing: '0.02em' }}
          >
            Get Udo on Google Play
          </a>
          <Link
            href="/#how-it-works"
            className="flex w-full items-center justify-center rounded-full border px-8 py-4 text-base transition-colors hover:bg-[#EBD9CE]"
            style={{ borderColor: '#7A5E4D', borderWidth: '1.5px', color: '#5A524D' }}
          >
            See How It Works
          </Link>
        </div>

        <p className="mt-5 text-center text-xs" style={{ color: '#9b8b83' }}>
          iOS app coming soon ·{' '}
          <Link href="/privacy" className="underline hover:opacity-70">Privacy</Link>
          {' '}·{' '}
          <Link href="/terms" className="underline hover:opacity-70">Terms</Link>
        </p>
      </div>
    </main>
  );
}
