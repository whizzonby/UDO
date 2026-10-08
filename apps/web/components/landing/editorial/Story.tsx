import appHome from '@/public/landing/app-home.jpg';
import appGuests from '@/public/landing/app-guests.jpg';
import appLive from '@/public/landing/app-live.jpg';
import { Display, Eyebrow, Phone } from './Primitives';
import { Reveal } from './Reveal';
import { color, container, narrow } from './tokens';

/** Section 3 — typography-led emotional pause after the hero. */
export function Statement() {
  return (
    <section aria-labelledby="statement-title" className="py-24 sm:py-32 lg:py-44" style={{ backgroundColor: color.ivory }}>
      <div className={narrow}>
        <Reveal>
          <span className="mx-auto mb-10 block h-14 w-px" style={{ backgroundColor: color.rose }} aria-hidden="true" />
          <Display id="statement-title" className="t-h2 text-center">
            Your wedding is more
            <br className="hidden sm:block" /> than a checklist.
          </Display>
        </Reveal>
        <Reveal delay={0.15}>
          <p className="t-lead mx-auto mt-8 max-w-[34rem] text-center leading-relaxed" style={{ color: color.body }}>
            It&rsquo;s the people, the moments, the little details and the memories you&rsquo;ll carry forever.
            Planning it should feel just as special.
          </p>
        </Reveal>
      </div>
    </section>
  );
}

const CALLOUTS = [
  {
    title: 'A little clarity, every day.',
    body: 'Today’s focus shows the one thing worth doing next, with an honest estimate of how long it takes.',
  },
  {
    title: 'Every day closer, counted.',
    body: 'Your home screen opens on your wedding date and the days left until forever.',
  },
  {
    title: 'Guests, at a glance.',
    body: 'See who has answered, who is still pending, and send a gentle follow-up in a tap.',
  },
  {
    title: 'A calm view of the big day.',
    body: 'On the day, Live mode shows what’s happening now and next, with broadcasts to guests and emergency contacts close at hand.',
  },
] as const;

/** Section 4 — the real app, composed rather than gridded. */
export function Showcase() {
  return (
    <section id="experience" aria-labelledby="showcase-title" className="scroll-mt-20 py-20 sm:py-28" style={{ backgroundColor: color.cream }}>
      <div className={container}>
        <div className="grid gap-10 lg:grid-cols-12 lg:items-end">
          <Reveal className="lg:col-span-7">
            <Eyebrow>Inside the app</Eyebrow>
            <Display id="showcase-title" className="t-h2">
              One beautiful place for every wedding detail.
            </Display>
          </Reveal>
          <Reveal delay={0.1} className="lg:col-span-4 lg:col-start-9">
            <p className="t-lead leading-relaxed" style={{ color: color.body }}>
              Guests, plans, budget, timeline and the day itself, organized the way you think about your wedding,
              not the way a spreadsheet does.
            </p>
          </Reveal>
        </div>

        <div className="mt-16 grid items-center gap-14 lg:mt-20 lg:grid-cols-12">
          {/* Overlapping device composition */}
          <div className="relative mx-auto h-[400px] w-full max-w-[520px] sm:h-[600px] lg:col-span-6 lg:h-[680px]">
            <Reveal y={40} className="absolute left-0 top-[12%] w-[42%] -rotate-[4deg]">
              <Phone src={appGuests} alt="Udo guest command centre showing RSVP progress: 3 guests, 0 confirmed, 3 pending" sizes="(min-width: 1024px) 220px, 40vw" />
            </Reveal>
            <Reveal y={40} delay={0.2} className="absolute right-0 top-[18%] w-[42%] rotate-[4deg]">
              <Phone src={appLive} alt="Udo live mode on the wedding day: what is happening now, the next event, and broadcast and emergency buttons" sizes="(min-width: 1024px) 220px, 40vw" />
            </Reveal>
            <Reveal y={40} delay={0.1} className="absolute left-1/2 top-0 z-10 w-[50%] -translate-x-1/2">
              <Phone src={appHome} alt="Udo home screen with the wedding countdown and today's focus" sizes="(min-width: 1024px) 260px, 48vw" />
            </Reveal>
          </div>

          {/* Benefit callouts */}
          <ol className="lg:col-span-5 lg:col-start-8">
            {CALLOUTS.map((c, i) => (
              <Reveal as="li" key={c.title} delay={i * 0.08} className="border-t border-[#E2DBD0] py-7 first:border-t-0 first:pt-0">
                <div className="flex gap-6">
                  <span className="font-display pt-1 text-[22px] font-medium tabular-nums" style={{ color: color.rose }} aria-hidden="true">
                    0{i + 1}
                  </span>
                  <div>
                    <h3 className="font-display text-[26px] font-medium leading-tight" style={{ color: color.forest }}>
                      {c.title}
                    </h3>
                    <p className="mt-2 text-[16px] leading-relaxed" style={{ color: color.body }}>
                      {c.body}
                    </p>
                  </div>
                </div>
              </Reveal>
            ))}
          </ol>
        </div>
      </div>
    </section>
  );
}
