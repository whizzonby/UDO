import { PLAY_STORE_URL } from '@/lib/appLinks';
import { C, Sparkle } from './shared';

export function FinalCTA() {
  return (
    <section className="overflow-hidden px-6 py-20 lg:px-8" style={{ backgroundColor: C.rose }}>
      <div className="mx-auto max-w-2xl text-center">
        <div className="relative inline-block">
          <Sparkle className="absolute -left-7 -top-5 h-6 w-6" color="rgba(255,255,255,0.8)" />
          <h2 className="text-[34px] leading-[1.1] tracking-tight sm:text-[44px]" style={{ color: C.white, fontWeight: 700 }}>
            Plan your wedding.
            <br />
            Keep your peace.
          </h2>
        </div>

        <p className="mx-auto mt-5 max-w-md text-[16px] leading-[1.6]" style={{ color: 'rgba(255,255,255,0.94)' }}>
          Everything you need, thoughtfully organized in one place — free to start.
        </p>

        <div className="mt-8 flex justify-center">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center justify-center rounded-full px-9 py-4 text-[16px] font-medium shadow-lg transition-all hover:opacity-95 hover:shadow-xl"
            style={{ backgroundColor: C.white, color: C.rose, letterSpacing: '0.01em' }}
          >
            Get Udo on Google Play
          </a>
        </div>

        <p className="mt-4 text-[13px]" style={{ color: 'rgba(255,255,255,0.85)' }}>
          Free on Android · iOS coming soon
        </p>
      </div>
    </section>
  );
}
