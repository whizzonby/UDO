import Link from 'next/link';
import type { ReactNode } from 'react';
import { PLAY_STORE_URL } from '@/lib/appLinks';

/* ------------------------------------------------------------------ */
/*  Palette — warm cream, dusty rose, taupe. No green.                 */
/* ------------------------------------------------------------------ */
export const C = {
  cream: '#FBF2EE',
  creamDeep: '#F6E7E0',
  white: '#FFFFFF',
  tan: '#EBD9CE',
  ink: '#2D2D2F',
  rose: '#D8909A',
  roseSoft: '#E8A0A8',
  taupe: '#7A5E4D',
  body: '#5A524D',
  bodyMuted: '#6B625C',
  line: 'rgba(122, 94, 77, 0.16)',
} as const;

/* ------------------------------------------------------------------ */
/*  Hand-drawn doodles — the page signature. Used sparingly.           */
/* ------------------------------------------------------------------ */
export function Sparkle({ className = '', color = C.roseSoft }: { className?: string; color?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" aria-hidden="true">
      <path d="M12 2.5v6M4.7 6l3.1 3.1M19.3 6l-3.1 3.1M2.5 14h4.5" />
    </svg>
  );
}

export function CurlyArrow({ className = '', color = C.roseSoft }: { className?: string; color?: string }) {
  return (
    <svg className={className} viewBox="0 0 48 64" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="M11 6C31 9 40 24 30 45" />
      <path d="M20 35l10 12 11-9" />
    </svg>
  );
}

export function Squiggle({ className = '', color = C.roseSoft }: { className?: string; color?: string }) {
  return (
    <svg className={className} viewBox="0 0 220 12" fill="none" stroke={color} strokeWidth="4" strokeLinecap="round" preserveAspectRatio="none" aria-hidden="true">
      <path d="M3 8c34-9 70-9 108 0s72 6 106-3" />
    </svg>
  );
}

export function GooglePlayGlyph({ className = '' }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 22 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <path d="M0.43 0.22C0.16 0.51 0 0.96 0 1.54v20.92c0 .58.16 1.03.44 1.32l.07.07 11.72-11.72v-.28L0.5.15.43.22z" fill="#00D2FF" />
      <path d="M16.07 15.97l-3.9-3.9v-.28l3.9-3.9.09.05 4.62 2.62c1.32.75 1.32 1.98 0 2.73l-4.62 2.62-.09.06z" fill="#FFC900" />
      <path d="M16.16 15.91L12.17 12 .43 23.74c.43.46 1.15.52 1.96.06l13.77-7.89" fill="#F9394B" />
      <path d="M16.16 8.09L2.39.2C1.58-.26.86-.2.43.26L12.17 12l4-3.91z" fill="#33C481" />
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/*  Section shell — consistent vertical rhythm + background.           */
/* ------------------------------------------------------------------ */
type Tone = 'cream' | 'white' | 'tan';
const toneBg: Record<Tone, string> = { cream: C.cream, white: C.white, tan: C.tan };

export function Section({
  children,
  tone = 'cream',
  id,
  className = '',
  width = 'prose',
}: {
  children: ReactNode;
  tone?: Tone;
  id?: string;
  className?: string;
  width?: 'prose' | 'wide' | 'full';
}) {
  const max = width === 'wide' ? 'max-w-6xl' : width === 'full' ? 'max-w-7xl' : 'max-w-2xl';
  return (
    <section id={id} className={`px-6 py-16 sm:py-20 lg:px-8 ${className}`} style={{ backgroundColor: toneBg[tone] }}>
      <div className={`mx-auto w-full ${max}`}>{children}</div>
    </section>
  );
}

/* ------------------------------------------------------------------ */
/*  Type primitives.                                                   */
/* ------------------------------------------------------------------ */
export function Eyebrow({ children }: { children: ReactNode }) {
  return (
    <span className="text-[12px] uppercase" style={{ color: C.rose, fontWeight: 700, letterSpacing: '0.16em' }}>
      {children}
    </span>
  );
}

export function Heading({
  children,
  className = '',
  size = 'md',
}: {
  children: ReactNode;
  className?: string;
  size?: 'md' | 'lg';
}) {
  const scale = size === 'lg' ? 'text-[34px] sm:text-[44px]' : 'text-[28px] sm:text-[36px]';
  return (
    <h2 className={`${scale} leading-[1.12] tracking-tight ${className}`} style={{ color: C.ink, fontWeight: 700 }}>
      {children}
    </h2>
  );
}

export function Accent({ children }: { children: ReactNode }) {
  return <span style={{ color: C.rose }}>{children}</span>;
}

export function Lead({ children, className = '' }: { children: ReactNode; className?: string }) {
  return (
    <p className={`text-[16px] leading-[1.7] sm:text-[17px] ${className}`} style={{ color: C.body }}>
      {children}
    </p>
  );
}

export function IconChip({
  children,
  size = 'md',
  filled = false,
}: {
  children: ReactNode;
  size?: 'sm' | 'md' | 'lg';
  filled?: boolean;
}) {
  const s = size === 'sm' ? 'h-8 w-8' : size === 'lg' ? 'h-12 w-12' : 'h-11 w-11';
  return (
    <span
      className={`inline-flex ${s} shrink-0 items-center justify-center rounded-full`}
      style={{ backgroundColor: filled ? C.rose : C.tan }}
    >
      {children}
    </span>
  );
}

export function Card({ children, tone = 'white', className = '' }: { children: ReactNode; tone?: Tone; className?: string }) {
  return (
    <div
      className={`rounded-[28px] p-7 sm:p-8 ${className}`}
      style={{ backgroundColor: toneBg[tone], border: `1.5px solid ${C.line}` }}
    >
      {children}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/*  Calls to action.                                                   */
/* ------------------------------------------------------------------ */
export function PlayStoreButton({
  children = 'Get Udo on Google Play',
  block = false,
}: {
  children?: ReactNode;
  block?: boolean;
}) {
  return (
    <a
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className={`inline-flex items-center justify-center rounded-full px-8 py-4 text-[16px] font-medium text-white shadow-md transition-all hover:opacity-95 hover:shadow-lg ${block ? 'w-full' : ''}`}
      style={{ backgroundColor: C.rose, letterSpacing: '0.01em' }}
    >
      {children}
    </a>
  );
}

export function GhostButton({
  href,
  children,
  block = false,
}: {
  href: string;
  children: ReactNode;
  block?: boolean;
}) {
  const cls = `inline-flex items-center justify-center rounded-full px-8 py-4 text-[16px] transition-colors hover:bg-[#EBD9CE] ${block ? 'w-full' : ''}`;
  const style = { borderColor: C.taupe, borderWidth: '1.5px', borderStyle: 'solid' as const, color: C.body };
  if (href.startsWith('#') || href.startsWith('/#')) {
    return (
      <a href={href} className={cls} style={style}>
        {children}
      </a>
    );
  }
  return (
    <Link href={href} className={cls} style={style}>
      {children}
    </Link>
  );
}

/* ------------------------------------------------------------------ */
/*  Google Play callout — the hero's signature element.                */
/* ------------------------------------------------------------------ */
export function GooglePlayCallout({ className = '' }: { className?: string }) {
  return (
    <a
      href={PLAY_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Download Udo on the Google Play Store"
      className={`relative inline-block transition-transform hover:-translate-y-0.5 ${className}`}
    >
      <span
        className="flex items-center gap-3.5 rounded-[22px] px-5 py-3.5"
        style={{ border: '1.5px solid #E7C6BE', backgroundColor: 'rgba(255,255,255,0.5)' }}
      >
        <GooglePlayGlyph className="h-7 w-7 shrink-0" />
        <span className="flex flex-col text-left leading-tight" style={{ color: C.rose }}>
          <span className="text-[11px] font-bold tracking-[0.16em]">DOWNLOAD TODAY</span>
          <span className="text-[15px] font-bold tracking-[0.02em]">ON THE GOOGLE PLAY STORE</span>
        </span>
      </span>
      <Sparkle className="absolute -left-3 -top-4 h-6 w-6" />
      <CurlyArrow className="absolute -right-9 -top-1 hidden h-16 w-11 sm:block" />
    </a>
  );
}
