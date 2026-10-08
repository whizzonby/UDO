import Link from 'next/link';
import joyRun from '@/public/landing/joy-run.jpg';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { Display, Eyebrow, Photo, StoreButtons } from './Primitives';
import { ImageReveal, Reveal } from './Reveal';
import { color, container } from './tokens';

/** Section 11 — emotional close with the strongest download CTA. */
export function FinalCta() {
  return (
    <section aria-labelledby="final-title" style={{ backgroundColor: color.forest }}>
      <div className="grid lg:grid-cols-2">
        <ImageReveal className="relative min-h-[56svh] lg:order-2 lg:min-h-[88svh]">
          <Photo
            src={joyRun}
            alt="A laughing bride and groom running hand in hand along a coastal road on their wedding day"
            sizes="(min-width: 1024px) 50vw, 100vw"
            className="absolute inset-0"
            position="55% 45%"
          />
        </ImageReveal>
        <div className="flex items-center lg:order-1">
          <Reveal className="w-full px-6 py-20 sm:px-12 lg:px-[max(3rem,calc((100vw-1240px)/2+3rem))]">
            <Eyebrow onDark>Begin with Udo</Eyebrow>
            <Display onDark className="t-h2">
              The beautiful beginning starts here.
            </Display>
            <p className="t-lead mt-7 max-w-[30rem] leading-relaxed" style={{ color: color.blush }}>
              Your wedding deserves a little more joy and a lot less stress. Bring your plans together with Udo.
            </p>
            <div className="mt-10">
              <StoreButtons placement="final" onDark />
            </div>
          </Reveal>
        </div>
      </div>
    </section>
  );
}

/** Section 12 — quiet, uncluttered footer. Only verified links and contacts. */
export function Footer() {
  const year = new Date().getFullYear();
  return (
    <footer style={{ backgroundColor: color.ivory }}>
      <div className={`${container} grid gap-12 py-16 sm:py-20 lg:grid-cols-12`}>
        <div className="lg:col-span-4">
          <p className="font-display text-[34px] font-semibold leading-none" style={{ color: color.forest }}>
            Udo
          </p>
          <p className="mt-4 max-w-[22rem] text-[15.5px] leading-relaxed" style={{ color: color.body }}>
            The calm wedding planner. Guests, plans, budget and the day itself, beautifully organized in one place.
          </p>
          <a href="mailto:hello@udowedding.com" className="mt-6 inline-block text-[15px] font-semibold underline underline-offset-4" style={{ color: color.forest }}>
            hello@udowedding.com
          </a>
        </div>

        <FooterColumn
          title="Explore"
          links={[
            ['/features', 'Features'],
            ['/how-it-works', 'How it works'],
            ['/pricing', 'Pricing'],
            ['/#faq', 'FAQ'],
          ]}
          className="lg:col-span-2 lg:col-start-5"
        />
        <FooterColumn
          title="Who it's for"
          links={[
            ['/#couples', 'For couples'],
            ['/#planners', 'For planners'],
          ]}
          className="lg:col-span-2"
        />
        <FooterColumn
          title="Legal"
          links={[
            ['/privacy', 'Privacy Policy'],
            ['/terms', 'Terms of Service'],
            ['/delete-account', 'Delete account'],
          ]}
          className="lg:col-span-2"
        />
        <div className="lg:col-span-2">
          <p className="mb-4 text-[12px] font-semibold uppercase tracking-[0.2em]" style={{ color: color.champagneDeep }}>
            Get the app
          </p>
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            data-store-link="footer-play"
            className="block text-[15px] font-medium underline-offset-4 hover:underline"
            style={{ color: color.charcoal }}
          >
            Google Play
          </a>
          <p className="mt-3 text-[15px]" style={{ color: color.body }}>
            iPhone soon
          </p>
        </div>
      </div>
      <div className="border-t border-[#E2DBD0]">
        <p className={`${container} py-6 text-[13.5px]`} style={{ color: color.body }}>
          © {year} WHIZZONBY LTD. All rights reserved.
        </p>
      </div>
    </footer>
  );
}

function FooterColumn({ title, links, className = '' }: { title: string; links: [string, string][]; className?: string }) {
  return (
    <nav aria-label={title} className={className}>
      <p className="mb-4 text-[12px] font-semibold uppercase tracking-[0.2em]" style={{ color: color.champagneDeep }}>
        {title}
      </p>
      <ul className="space-y-3">
        {links.map(([href, label]) => (
          <li key={href}>
            <Link href={href} className="text-[15px] font-medium underline-offset-4 hover:underline" style={{ color: color.charcoal }}>
              {label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
