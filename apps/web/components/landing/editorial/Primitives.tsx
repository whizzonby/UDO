import Image, { type StaticImageData } from 'next/image';
import type { ReactNode } from 'react';
import { APP_STORE_URL, PLAY_STORE_URL } from '@/lib/appLinks';
import { color } from './tokens';

/** Small uppercase label above a heading. */
export function Eyebrow({ children, onDark = false }: { children: ReactNode; onDark?: boolean }) {
  return (
    <p
      className="mb-5 text-[12px] font-semibold uppercase tracking-[0.22em]"
      style={{ color: onDark ? color.champagne : color.champagneDeep }}
    >
      {children}
    </p>
  );
}

/** Editorial display heading (serif). Size is controlled by the caller. */
export function Display({
  as: Tag = 'h2',
  children,
  className = '',
  onDark = false,
  id,
}: {
  as?: 'h1' | 'h2' | 'h3';
  children: ReactNode;
  className?: string;
  onDark?: boolean;
  id?: string;
}) {
  return (
    <Tag
      id={id}
      className={`font-display font-medium leading-[1.02] tracking-[-0.015em] ${className}`}
      style={{ color: onDark ? color.ivory : color.forest }}
    >
      {children}
    </Tag>
  );
}

/** A real app screenshot in a restrained phone frame (no gloss, no glow). */
export function Phone({
  src,
  alt,
  className = '',
  priority = false,
  sizes = '(min-width: 1024px) 300px, 60vw',
}: {
  src: StaticImageData;
  alt: string;
  className?: string;
  priority?: boolean;
  sizes?: string;
}) {
  return (
    <div
      className={`relative aspect-[9/16] w-full overflow-hidden rounded-[2rem] border-[6px] ${className}`}
      style={{ borderColor: color.charcoal, backgroundColor: color.charcoal, boxShadow: '0 30px 60px -30px rgba(37,41,37,0.45)' }}
    >
      <Image src={src} alt={alt} fill sizes={sizes} priority={priority} className="object-cover object-top" placeholder="blur" />
    </div>
  );
}

/** Google Play badge-style link + honest App Store state. */
export function StoreButtons({ placement, onDark = false }: { placement: string; onDark?: boolean }) {
  const solid = onDark
    ? { backgroundColor: color.ivory, color: color.forest }
    : { backgroundColor: color.forest, color: color.ivory };

  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
      <a
        href={PLAY_STORE_URL}
        target="_blank"
        rel="noopener noreferrer"
        data-store-link={`${placement}-play`}
        className="group inline-flex min-h-[52px] items-center justify-center gap-3 rounded-md px-6 text-[15px] font-semibold transition-transform duration-300 hover:-translate-y-0.5 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4"
        style={{ ...solid, outlineColor: onDark ? color.ivory : color.forest }}
      >
        <PlayGlyph />
        <span>
          <span className="block text-[11px] font-medium uppercase tracking-[0.14em] opacity-80">Get it on</span>
          <span className="block leading-tight">Google Play</span>
        </span>
      </a>
      {APP_STORE_URL ? (
        <a
          href={APP_STORE_URL}
          target="_blank"
          rel="noopener noreferrer"
          data-store-link={`${placement}-appstore`}
          className="inline-flex min-h-[52px] items-center justify-center gap-3 rounded-md border px-6 text-[15px] font-semibold transition-transform duration-300 hover:-translate-y-0.5"
          style={{ borderColor: onDark ? color.ivory : color.forest, color: onDark ? color.ivory : color.forest }}
        >
          <AppleGlyph />
          <span>
            <span className="block text-[11px] font-medium uppercase tracking-[0.14em] opacity-80">Download on the</span>
            <span className="block leading-tight">App Store</span>
          </span>
        </a>
      ) : (
        <p
          className="inline-flex min-h-[52px] items-center justify-center gap-3 rounded-md border border-dashed px-6 text-[14px] font-medium"
          style={{ borderColor: onDark ? color.lineOnForest : color.line, color: onDark ? color.blush : color.body }}
        >
          <AppleGlyph />
          iPhone app coming soon
        </p>
      )}
    </div>
  );
}

/** Full-bleed or framed photograph with a soft colour fallback while loading. */
export function Photo({
  src,
  alt,
  sizes,
  className = '',
  priority = false,
  position = 'center',
}: {
  src: StaticImageData;
  alt: string;
  sizes: string;
  className?: string;
  priority?: boolean;
  position?: string;
}) {
  return (
    // Callers pass `absolute inset-0` for full-bleed photos; only default to
    // `relative` otherwise (both classes together let `relative` win → 0 height).
    <div
      className={`overflow-hidden ${className.split(' ').includes('absolute') ? '' : 'relative '}${className}`}
      style={{ backgroundColor: color.cream }}
    >
      <Image
        src={src}
        alt={alt}
        fill
        sizes={sizes}
        priority={priority}
        placeholder="blur"
        className="object-cover transition-transform duration-[1200ms] ease-out group-hover:scale-[1.03]"
        style={{ objectPosition: position }}
      />
    </div>
  );
}

function PlayGlyph() {
  return (
    <svg width="20" height="22" viewBox="0 0 20 22" aria-hidden="true" fill="currentColor">
      <path d="M1.2.3 11.6 10.7 1.2 21.1A1.6 1.6 0 0 1 .5 19.8V1.6c0-.5.3-1 .7-1.3Zm11.5 11.5 2.7 2.7-11.5 6.6 8.8-9.3Zm0-2.2L3.9.3l11.5 6.6-2.7 2.7Zm3.9-1.7 2.7 1.6c.9.5.9 1.9 0 2.4l-2.7 1.6-3-3 3-2.6Z" />
    </svg>
  );
}

function AppleGlyph() {
  return (
    <svg width="18" height="22" viewBox="0 0 18 22" aria-hidden="true" fill="currentColor">
      <path d="M14.9 11.7c0-2.6 2.1-3.8 2.2-3.9-1.2-1.8-3.1-2-3.8-2-1.6-.2-3.1.9-3.9.9-.8 0-2-.9-3.4-.9-1.7 0-3.3 1-4.2 2.6-1.8 3.1-.5 7.7 1.3 10.2.9 1.2 1.9 2.6 3.2 2.6 1.3-.1 1.8-.8 3.3-.8 1.6 0 2 .8 3.4.8 1.4 0 2.3-1.3 3.1-2.5 1-1.4 1.4-2.8 1.4-2.9-.1 0-2.7-1-2.6-4.1ZM12.4 4.1c.7-.9 1.2-2 1-3.2-1 0-2.3.7-3 1.6-.7.8-1.3 2-1.1 3.1 1.2.1 2.4-.6 3.1-1.5Z" />
    </svg>
  );
}
