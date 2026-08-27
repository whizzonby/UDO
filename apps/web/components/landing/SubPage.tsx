import type { ReactNode } from 'react';
import { Header } from './Header';
import { Footer } from './Footer';
import { FinalCTA } from './FinalCTA';
import { C, Eyebrow, Lead } from './shared';

export function SubPage({
  eyebrow,
  title,
  intro,
  children,
}: {
  eyebrow: string;
  title: ReactNode;
  intro?: ReactNode;
  children: ReactNode;
}) {
  return (
    <div className="min-h-screen" style={{ backgroundColor: C.cream }}>
      <Header />

      <section className="px-6 pb-6 pt-14 lg:px-8" style={{ backgroundColor: C.cream }}>
        <div className="mx-auto max-w-2xl text-center">
          <Eyebrow>{eyebrow}</Eyebrow>
          <h1
            className="mt-3 text-[32px] leading-[1.1] tracking-tight sm:text-[42px]"
            style={{ color: C.ink, fontWeight: 700 }}
          >
            {title}
          </h1>
          {intro ? <Lead className="mx-auto mt-4 max-w-xl">{intro}</Lead> : null}
        </div>
      </section>

      {children}

      <FinalCTA />
      <Footer />
    </div>
  );
}
