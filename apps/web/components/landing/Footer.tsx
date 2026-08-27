import Link from 'next/link';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { C, GooglePlayGlyph } from './shared';

export function Footer() {
  return (
    <footer className="px-6 py-14 lg:px-8" style={{ backgroundColor: C.white }}>
      <div className="mx-auto max-w-2xl">
        <div className="flex flex-col items-center gap-8 text-center">
          {/* Wordmark */}
          <div className="flex items-center gap-3">
            <span
              className="flex h-9 w-9 items-center justify-center rounded-full text-[15px] font-bold text-white"
              style={{ background: 'linear-gradient(135deg, #E8A0A8 0%, #D8909A 100%)' }}
            >
              U
            </span>
            <span className="text-[22px] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
              Udo
            </span>
          </div>

          {/* Store badges */}
          <div className="flex flex-col items-center gap-3 sm:flex-row">
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Get it on Google Play"
              className="flex items-center gap-3 rounded-2xl px-5 py-3 transition-opacity hover:opacity-80"
              style={{ border: `1.5px solid ${C.ink}`, minWidth: 176 }}
            >
              <GooglePlayGlyph className="h-6 w-6" />
              <span className="flex flex-col leading-none text-left" style={{ color: C.ink }}>
                <span className="text-[10px]">Get it on</span>
                <span className="text-[17px] font-semibold tracking-tight">Google Play</span>
              </span>
            </a>

            <div
              className="flex items-center gap-3 rounded-2xl px-5 py-3 opacity-50"
              style={{ border: `1.5px solid ${C.line}`, minWidth: 176 }}
              aria-label="iOS app coming soon"
            >
              <svg width="20" height="24" viewBox="0 0 22 26" fill="none" aria-hidden="true">
                <path
                  d="M18.07 13.77c-.03-3.04 2.48-4.51 2.59-4.58-1.41-2.06-3.61-2.35-4.39-2.38-1.87-.19-3.66 1.1-4.61 1.1-.96 0-2.44-1.08-4.01-1.05-2.06.03-3.97 1.2-5.02 3.04-2.15 3.72-.55 9.22 1.54 12.24 1.03 1.48 2.25 3.14 3.85 3.08 1.55-.06 2.13-.99 4.01-.99 1.87 0 2.4.99 4.03.96 1.66-.03 2.72-1.51 3.74-3 1.18-1.72 1.67-3.39 1.7-3.47-.04-.02-3.42-1.31-3.45-5.22z"
                  fill={C.ink}
                />
              </svg>
              <span className="flex flex-col leading-none text-left" style={{ color: C.ink }}>
                <span className="text-[10px]">iOS app</span>
                <span className="text-[17px] font-semibold tracking-tight">Coming soon</span>
              </span>
            </div>
          </div>

          {/* Links */}
          <nav className="flex flex-wrap items-center justify-center gap-x-7 gap-y-2 text-[14px]">
            <a href="#features" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>Features</a>
            <a href="#how-it-works" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>How it works</a>
            <a href="#pricing" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>Pricing</a>
            <Link href="/privacy" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>Privacy</Link>
            <Link href="/terms" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>Terms</Link>
            <Link href="/delete-account" className="transition-opacity hover:opacity-70" style={{ color: C.body }}>Delete account</Link>
          </nav>

          <div className="space-y-1.5 border-t pt-7" style={{ borderColor: C.line, width: '100%' }}>
            <p className="text-[13px] italic" style={{ color: C.bodyMuted }}>
              Make your wedding day a peaceful one.
            </p>
            <p className="text-[13px]" style={{ color: C.bodyMuted }}>
              © 2026 Udo. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
}
