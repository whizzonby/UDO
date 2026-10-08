'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { usePathname } from 'next/navigation';
import { Menu, X } from 'lucide-react';
import { AnimatePresence, motion, useReducedMotion } from 'motion/react';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { color, container, ease } from './tokens';

/** One menu for every marketing page. Home sections are linked as /#id. */
export const LINKS = [
  { href: '/features', label: 'Features' },
  { href: '/how-it-works', label: 'How it works' },
  { href: '/pricing', label: 'Pricing' },
  { href: '/#couples', label: 'For couples' },
  { href: '/#planners', label: 'For planners' },
  { href: '/#faq', label: 'FAQ' },
] as const;

export function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const reduce = useReducedMotion();
  const pathname = usePathname();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('keydown', onKey);
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = '';
    };
  }, [open]);

  const solid = scrolled || open;

  return (
    <header
      className="fixed inset-x-0 top-0 z-50 transition-[background-color,border-color] duration-500"
      style={{
        backgroundColor: solid ? color.ivory : 'transparent',
        borderBottom: `1px solid ${solid ? color.line : 'transparent'}`,
      }}
    >
      <nav aria-label="Main" className={`${container} flex h-[68px] items-center justify-between`}>
        <Link href="/" className="flex items-center gap-2.5" aria-label="Udo home">
          <span
            className="grid h-9 w-9 place-items-center rounded-full text-[15px]"
            style={{ backgroundColor: color.forest, color: color.ivory }}
            aria-hidden="true"
          >
            <HeartMark />
          </span>
          <span className="font-display text-[26px] font-semibold leading-none" style={{ color: color.forest }}>
            Udo
          </span>
        </Link>

        <ul className="hidden items-center gap-7 lg:flex">
          {LINKS.map((l) => (
            <li key={l.href}>
              <a
                href={l.href}
                aria-current={pathname === l.href ? 'page' : undefined}
                className={`text-[14.5px] font-medium underline-offset-[6px] transition-colors hover:underline ${pathname === l.href ? 'underline' : ''}`}
                style={{ color: color.charcoal, textDecorationColor: color.rose }}
              >
                {l.label}
              </a>
            </li>
          ))}
        </ul>

        <div className="flex items-center gap-2">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            data-store-link="nav-play"
            className="hidden min-h-[42px] items-center rounded-md px-5 text-[14px] font-semibold transition-transform duration-300 hover:-translate-y-0.5 sm:inline-flex"
            style={{ backgroundColor: color.forest, color: color.ivory }}
          >
            Get the app
          </a>
          <button
            type="button"
            onClick={() => setOpen((v) => !v)}
            aria-expanded={open}
            aria-controls="mobile-menu"
            aria-label={open ? 'Close menu' : 'Open menu'}
            className="grid h-11 w-11 place-items-center rounded-md lg:hidden"
            style={{ color: color.forest }}
          >
            {open ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </nav>

      <AnimatePresence>
        {open && (
          <motion.div
            id="mobile-menu"
            initial={reduce ? false : { opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={reduce ? undefined : { opacity: 0, y: -8 }}
            transition={{ duration: 0.35, ease }}
            className="fixed inset-x-0 bottom-0 top-[68px] overflow-y-auto lg:hidden"
            style={{ backgroundColor: color.ivory }}
          >
            <ul className={`${container} flex flex-col pt-6`}>
              {LINKS.map((l, i) => (
                <li key={l.href} className="border-b" style={{ borderColor: color.line }}>
                  <a
                    href={l.href}
                    aria-current={pathname === l.href ? 'page' : undefined}
                    onClick={() => setOpen(false)}
                    className="flex items-baseline justify-between py-5"
                    style={{ color: color.forest }}
                  >
                    <span className="font-display text-[34px] font-medium leading-none">{l.label}</span>
                    <span className="text-[13px] font-semibold tabular-nums" style={{ color: color.roseDeep }}>
                      0{i + 1}
                    </span>
                  </a>
                </li>
              ))}
            </ul>
            <div className={`${container} py-8`}>
              <a
                href={PLAY_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                data-store-link="mobile-menu-play"
                className="flex min-h-[54px] w-full items-center justify-center rounded-md text-[16px] font-semibold"
                style={{ backgroundColor: color.forest, color: color.ivory }}
              >
                Get Udo on Google Play
              </a>
              <p className="mt-3 text-center text-[13px]" style={{ color: color.body }}>
                iPhone app coming soon
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}

function HeartMark() {
  return (
    <svg width="16" height="15" viewBox="0 0 24 22" fill="currentColor" aria-hidden="true">
      <path d="M12 21.4 10.3 19.8C4.2 14.3.2 10.7.2 6.3.2 2.7 3 0 6.5 0c2 0 3.9.9 5.5 2.4C13.6.9 15.5 0 17.5 0 21 0 23.8 2.7 23.8 6.3c0 4.4-4 8-10.1 13.5L12 21.4Z" />
    </svg>
  );
}
