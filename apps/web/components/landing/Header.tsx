import Link from 'next/link';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { C } from './shared';

export function Header() {
  return (
    <header
      className="sticky top-0 z-50 border-b backdrop-blur-md"
      style={{ backgroundColor: 'rgba(251, 242, 238, 0.92)', borderColor: C.line }}
    >
      <div className="mx-auto flex h-[68px] max-w-6xl items-center justify-between px-6 lg:px-8">
        <Link href="/" className="flex items-center gap-3">
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

        <div className="flex items-center gap-3 sm:gap-4">
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
            className="rounded-full px-5 py-2.5 text-[15px] font-medium text-white transition-opacity hover:opacity-90"
            style={{ backgroundColor: C.roseSoft }}
          >
            Get the App
          </a>
        </div>
      </div>
    </header>
  );
}
