import type { Metadata } from 'next';
import foreheadKiss from '@/public/landing/forehead-kiss.jpg';
import { Shell, PageHeader, Display, Eyebrow, Reveal } from '@/components/landing/editorial/Shell';
import { HowItWorks } from '@/components/landing/editorial/Journey';
import { Photo } from '@/components/landing/editorial/Primitives';
import { ImageReveal } from '@/components/landing/editorial/Reveal';
import { color, container } from '@/components/landing/editorial/tokens';

export const metadata: Metadata = {
  title: 'How Udo Works | Udo Wedding Planner',
  description:
    'How Udo takes you from the first guest list to the wedding day: set up your wedding in a minute, bring every detail together, and always know what to do next.',
  alternates: { canonical: '/how-it-works' },
};

/** What actually happens in the app after you sign up. */
const FIRST_DAYS = [
  {
    when: 'Minute one',
    title: 'Three quick questions',
    body: 'Your name, your partner’s name and your date. Skip anything you don’t know yet; if you haven’t picked a date, just choose “I haven’t decided yet”.',
  },
  {
    when: 'Straight away',
    title: 'Your home screen comes to life',
    body: 'Udo greets you with your countdown and today’s focus: one useful thing to do next, with an estimate of how long it takes.',
  },
  {
    when: 'When you’re ready',
    title: 'Complete your wedding profile',
    body: 'A short checklist on Home walks you through budget, guests and the rest, one small section at a time.',
  },
  {
    when: 'As plans firm up',
    title: 'Send your guests their links',
    body: 'Each guest gets a personal link by email, SMS or WhatsApp to RSVP and find the details. No app needed on their side.',
  },
  {
    when: 'Whenever you need help',
    title: 'Bring in your people',
    body: 'On a paid plan, invite your partner, a planner or helpers, each seeing exactly what their role needs.',
  },
] as const;

export default function HowItWorksPage() {
  return (
    <Shell>
      <PageHeader
        eyebrow="How it works"
        title="Calm planning, from the first idea to the last dance."
        intro="Udo starts small and grows with your plans, so you never face a wall of tasks. Here’s how it fits into the months before your wedding."
      />

      <HowItWorks />

      <section aria-labelledby="first-days-title" style={{ backgroundColor: color.cream }}>
        <div className={`${container} grid gap-14 py-20 sm:py-28 lg:grid-cols-12`}>
          <div className="lg:col-span-5">
            <div className="lg:sticky lg:top-28">
              <Reveal>
                <Eyebrow>Your first days with Udo</Eyebrow>
                <Display id="first-days-title" className="t-h3">
                  What happens after you download.
                </Display>
              </Reveal>
              <ImageReveal className="mt-10">
                <Photo
                  src={foreheadKiss}
                  alt="A groom gently kissing his bride's forehead among green trees"
                  sizes="(min-width: 1024px) 38vw, 92vw"
                  className="aspect-[4/5] rounded-t-[999px]"
                  position="45% 40%"
                />
              </ImageReveal>
            </div>
          </div>

          <div className="relative lg:col-span-6 lg:col-start-7">
          <span className="absolute bottom-6 left-[7px] top-3 w-px" style={{ backgroundColor: color.rose }} aria-hidden="true" />
          <ol>
            {FIRST_DAYS.map((s, i) => (
              <Reveal as="li" key={s.title} delay={i * 0.05} className="relative pb-12 pl-10 last:pb-0">
                <span
                  className="absolute left-0 top-2 h-[15px] w-[15px] rounded-full border-2"
                  style={{ borderColor: color.rose, backgroundColor: color.cream }}
                  aria-hidden="true"
                />
                <p className="text-[12px] font-semibold uppercase tracking-[0.2em]" style={{ color: color.champagneDeep }}>
                  {s.when}
                </p>
                <h3 className="font-display mt-2 text-[30px] font-medium leading-tight" style={{ color: color.forest }}>
                  {s.title}
                </h3>
                <p className="mt-3 max-w-[30rem] text-[16.5px] leading-relaxed" style={{ color: color.body }}>
                  {s.body}
                </p>
              </Reveal>
            ))}
          </ol>
          </div>
        </div>
      </section>
    </Shell>
  );
}
