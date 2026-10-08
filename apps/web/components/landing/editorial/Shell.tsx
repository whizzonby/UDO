import { Cormorant_Garamond, DM_Sans } from 'next/font/google';
import type { ReactNode } from 'react';
import '@/app/landing.css';
import { Nav } from './Nav';
import { FinalCta, Footer } from './Closing';
import { Display, Eyebrow } from './Primitives';
import { Reveal } from './Reveal';
import { color, container } from './tokens';

const display = Cormorant_Garamond({
  subsets: ['latin'],
  weight: ['500', '600'],
  display: 'swap',
  variable: '--font-landing-display',
});

const sans = DM_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  display: 'swap',
  variable: '--font-landing-sans',
});

/**
 * Shared frame for every marketing page (home, features, pricing, …):
 * same fonts, menu, closing download section and footer.
 */
export function Shell({ children, finalCta = true }: { children: ReactNode; finalCta?: boolean }) {
  return (
    <div className={`landing ${display.variable} ${sans.variable}`}>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[60] focus:rounded-md focus:bg-[#243B35] focus:px-4 focus:py-3 focus:text-[#F8F6F1]"
      >
        Skip to content
      </a>
      {/* Without JS, scroll-reveal content would stay at opacity 0 — show it. */}
      <noscript>
        <style>{`.landing [style*="opacity:0"]{opacity:1!important;transform:none!important}`}</style>
      </noscript>
      <Nav />
      <main id="main">
        {children}
        {finalCta && <FinalCta />}
      </main>
      <Footer />
    </div>
  );
}

/** Editorial page opener for the inner pages. */
export function PageHeader({
  eyebrow,
  title,
  intro,
  aside,
}: {
  eyebrow: string;
  title: ReactNode;
  intro: ReactNode;
  aside?: ReactNode;
}) {
  return (
    <section aria-labelledby="page-title" className="pt-[68px]" style={{ backgroundColor: color.ivory }}>
      <div className={`${container} grid items-end gap-10 pb-16 pt-14 sm:pb-20 sm:pt-20 lg:grid-cols-12`}>
        <div className={aside ? 'lg:col-span-7' : 'lg:col-span-9'}>
          <p className="rise mb-6 flex items-center gap-3 text-[12px] font-semibold uppercase tracking-[0.24em]" style={{ color: color.champagneDeep }}>
            <span className="h-px w-8" style={{ backgroundColor: color.rose }} aria-hidden="true" />
            {eyebrow}
          </p>
          <Display as="h1" id="page-title" className="t-h2 rise rise-1">
            {title}
          </Display>
          <p className="t-lead rise rise-2 mt-7 max-w-[36rem] leading-relaxed" style={{ color: color.body }}>
            {intro}
          </p>
        </div>
        {aside && <div className="rise rise-3 lg:col-span-4 lg:col-start-9">{aside}</div>}
      </div>
    </section>
  );
}

export { Display, Eyebrow, Reveal };
