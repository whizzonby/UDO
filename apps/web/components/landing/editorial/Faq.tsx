'use client';

import * as Accordion from '@radix-ui/react-accordion';
import { Plus } from 'lucide-react';
import { Display, Eyebrow } from './Primitives';
import { FAQS } from './faqData';
import { color, narrow } from './tokens';

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}

type QA = { readonly q: string; readonly a: string };

export function Faq({
  items = FAQS,
  title = 'Everything you might be wondering.',
  id = 'faq',
}: {
  items?: readonly QA[];
  title?: string;
  id?: string;
}) {
  return (
    <section id={id} aria-labelledby={`${id}-title`} className="scroll-mt-20 py-20 sm:py-28" style={{ backgroundColor: color.ivory }}>
      <div className={narrow}>
        <Eyebrow>Questions</Eyebrow>
        <Display id={`${id}-title`} className="t-h3">
          {title}
        </Display>

        <Accordion.Root
          type="single"
          collapsible
          className="mt-12 border-b border-[#E2DBD0]"
          onValueChange={(value) => {
            if (value) window.gtag?.('event', 'faq_open', { question: value });
          }}
        >
          {items.map((f) => (
            <Accordion.Item key={f.q} value={f.q} className="border-t border-[#E2DBD0]">
              <Accordion.Header>
                <Accordion.Trigger
                  className="group flex w-full items-center justify-between gap-6 py-6 text-left focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-4"
                  style={{ outlineColor: color.forest }}
                >
                  <span className="font-display text-[24px] font-medium leading-snug sm:text-[27px]" style={{ color: color.forest }}>
                    {f.q}
                  </span>
                  <Plus
                    size={22}
                    aria-hidden="true"
                    className="shrink-0 transition-transform duration-300 group-data-[state=open]:rotate-45"
                    style={{ color: color.roseDeep }}
                  />
                </Accordion.Trigger>
              </Accordion.Header>
              <Accordion.Content className="faq-content overflow-hidden">
                <p className="max-w-[40rem] pb-7 text-[17px] leading-relaxed" style={{ color: color.body }}>
                  {f.a}
                  {f.q === 'Is Udo free?' && (
                    <>
                      {' '}
                      <a href="/pricing" className="font-semibold underline underline-offset-4" style={{ color: color.forest }}>
                        View pricing
                      </a>
                    </>
                  )}
                </p>
              </Accordion.Content>
            </Accordion.Item>
          ))}
        </Accordion.Root>
      </div>
    </section>
  );
}
