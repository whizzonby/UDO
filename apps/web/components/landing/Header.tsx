'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Menu, X } from 'lucide-react';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { C, NAV } from './shared';

export function Header() {
  const [open, setOpen] = useState(false);

  return (
    <header
      className="sticky top-0 z-50 border-b backdrop-blur-md"
      style={{ backgroundColor: 'rgba(251, 242, 238, 0.92)', borderColor: C.line }}
    >
      <div className="mx-auto flex h-[68px] max-w-6xl items-center justify-between px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3" onClick={() => setOpen(false)}>
          <span
            className="flex h-10 w-10 items-center justify-center rounded-full text-[17px] font-bold text-white"
            style={{ background: 'linear-gradient(135deg, #E8A0A8 0%, #D8909A 100%)' }}
          >
            U
          </span>
          <span className="text-[24px] tracking-tight" style={{ color: C.ink, fontWeight: 700 }}>
            Udo
          </span>
        </Link>

        {/* Desktop nav */}
        <nav className="hidden items-center gap-8 md:flex">
          {NAV.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-[15px] transition-opacity hover:opacity-70"
              style={{ color: C.body, fontWeight: 500 }}
            >
              {item.label}
            </Link>
          ))}
          <Link
            href="/login"
            className="text-[15px] transition-opacity hover:opacity-70"
            style={{ color: C.body, fontWeight: 500 }}
          >
            Sign in
          </Link>
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            data-store-link="header"
            className="rounded-full px-5 py-2.5 text-[15px] font-medium text-white transition-opacity hover:opacity-90"
            style={{ backgroundColor: C.roseSoft }}
          >
            Get the App
          </a>
        </nav>

        {/* Mobile: app button + hamburger */}
        <div className="flex items-center gap-2 md:hidden">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            data-store-link="header_mobile"
            className="rounded-full px-4 py-2 text-[14px] font-medium text-white"
            style={{ backgroundColor: C.roseSoft }}
          >
            Get the App
          </a>
          <button
            type="button"
            aria-label={open ? 'Close menu' : 'Open menu'}
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
            className="flex h-10 w-10 items-center justify-center rounded-full"
            style={{ color: C.ink }}
          >
            {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </div>

      {/* Mobile menu panel */}
      {open && (
        <div className="border-t md:hidden" style={{ borderColor: C.line, backgroundColor: C.cream }}>
          <nav className="mx-auto flex max-w-6xl flex-col px-6 py-2">
            {NAV.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                className="border-b py-3.5 text-[16px]"
                style={{ color: C.body, borderColor: C.line, fontWeight: 500 }}
              >
                {item.label}
              </Link>
            ))}
            <Link
              href="/login"
              onClick={() => setOpen(false)}
              className="py-3.5 text-[16px]"
              style={{ color: C.body, fontWeight: 500 }}
            >
              Sign in
            </Link>
          </nav>
        </div>
      )}
    </header>
  );
}
