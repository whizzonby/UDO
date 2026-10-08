import Image from 'next/image';
import rings from '@/public/landing/rings.jpg';
import tableDetail from '@/public/landing/table-detail.jpg';
import appGuests from '@/public/landing/app-guests.jpg';
import appHome from '@/public/landing/app-home.jpg';
import { Display, Eyebrow, Phone, Photo } from './Primitives';
import { ImageReveal, Reveal } from './Reveal';
import { color, container } from './tokens';

function Lead({ children }: { children: React.ReactNode }) {
  return (
    <p className="t-lead mt-6 max-w-[32rem] leading-relaxed" style={{ color: color.body }}>
      {children}
    </p>
  );
}

function Points({ items }: { items: readonly string[] }) {
  return (
    <ul className="mt-8 max-w-[32rem]">
      {items.map((t) => (
        <li key={t} className="flex gap-4 border-t border-[#E2DBD0] py-4 text-[16px] leading-relaxed" style={{ color: color.charcoal }}>
          <span className="mt-[0.7em] h-px w-5 shrink-0" style={{ backgroundColor: color.rose }} aria-hidden="true" />
          {t}
        </li>
      ))}
    </ul>
  );
}

/** Section 7 — four confirmed capabilities, four different compositions. */
export function DeepDives() {
  return (
    <section aria-label="Udo features in detail" style={{ backgroundColor: color.ivory }}>
      {/* 1 · Guests — photograph with an overlapping phone */}
      <div className={`${container} grid items-center gap-14 pb-28 pt-20 sm:pb-36 sm:pt-28 lg:grid-cols-12`}>
        <div className="relative lg:col-span-6">
          <ImageReveal>
            <Photo
              src={rings}
              alt="Close-up of a bride placing a wedding ring on her partner's hand"
              sizes="(min-width: 1024px) 45vw, 92vw"
              className="aspect-[5/4] w-[86%] rounded-sm"
              position="55% 62%"
            />
          </ImageReveal>
          <Reveal y={40} delay={0.15} className="absolute bottom-[-18%] right-0 w-[38%] max-w-[220px]">
            <Phone src={appGuests} alt="Udo guest overview with RSVP progress and a reminder of who still needs to answer" sizes="230px" />
          </Reveal>
        </div>
        <Reveal className="mt-10 lg:col-span-5 lg:col-start-8 lg:mt-0">
          <Eyebrow>Guests &amp; RSVPs</Eyebrow>
          <Display className="t-h3">Every guest, thoughtfully organized.</Display>
          <Lead>
            Know who&rsquo;s coming, who still needs a nudge and who&rsquo;s sitting where, without a single
            spreadsheet.
          </Lead>
          <Points
            items={[
              'Personal guest links by email, SMS or WhatsApp, with no app or login needed for guests',
              'RSVPs, meal choices and dietary needs collected in one place',
              'A seating planner that stays in step with your guest list',
            ]}
          />
        </Reveal>
      </div>

      {/* 2 · Plans — a typographic ledger on cream, no device */}
      <div style={{ backgroundColor: color.cream }}>
        <div className={`${container} grid gap-12 py-20 sm:py-28 lg:grid-cols-12`}>
          <Reveal className="lg:col-span-5">
            <Eyebrow>Plans &amp; timeline</Eyebrow>
            <Display className="t-h3">Your plans, all in one place.</Display>
            <Lead>Tasks, deadlines and the shape of the day, kept together so nothing slips quietly out of view.</Lead>
          </Reveal>
          <Reveal delay={0.1} className="lg:col-span-6 lg:col-start-7">
            <dl className="grid sm:grid-cols-2">
              {[
                ['Checklist', 'Tasks that tell you what matters next, at your own pace.'],
                ['Timeline', 'Your ceremony, reception and every related event, in order.'],
                ['Reminders', 'Gentle prompts before RSVP deadlines and vendor payments.'],
                ['Vendors', 'Contacts and details for everyone helping make the day happen.'],
              ].map(([term, desc]) => (
                <div key={term} className="border-t border-[#D8CFC2] py-6 sm:pr-8">
                  <dt className="font-display text-[28px] font-medium" style={{ color: color.forest }}>
                    {term}
                  </dt>
                  <dd className="mt-2 text-[16px] leading-relaxed" style={{ color: color.body }}>
                    {desc}
                  </dd>
                </div>
              ))}
            </dl>
          </Reveal>
        </div>
      </div>

      {/* 3 · Countdown — arch-cropped detail of the real home screen */}
      <div className={`${container} grid items-center gap-14 py-20 sm:py-28 lg:grid-cols-12`}>
        <Reveal className="order-2 lg:order-1 lg:col-span-5">
          <Eyebrow>Your dashboard</Eyebrow>
          <Display className="t-h3">Celebrate every day closer.</Display>
          <Lead>
            Udo opens on your date, your countdown and one thoughtful next step, so planning feels like
            anticipation rather than admin.
          </Lead>
        </Reveal>
        <ImageReveal className="order-1 lg:order-2 lg:col-span-6 lg:col-start-7">
          <div className="relative mx-auto aspect-[4/5] w-full max-w-[460px] overflow-hidden rounded-t-[999px] border" style={{ borderColor: color.line, backgroundColor: color.cream }}>
            <Image
              src={appHome}
              alt="Detail of the Udo home screen: Good morning, 206 days until forever"
              fill
              sizes="(min-width: 1024px) 460px, 92vw"
              placeholder="blur"
              className="object-cover"
              style={{ objectPosition: '50% 62%' }}
            />
          </div>
        </ImageReveal>
      </div>

      {/* 4 · Budget & details — photograph beside a ruled list */}
      <div className={`${container} grid items-center gap-14 pb-24 sm:pb-32 lg:grid-cols-12`}>
        <ImageReveal className="lg:col-span-6">
          <Photo
            src={tableDetail}
            alt="A wedding place setting with a wooden charger, white plate, sprig of greenery and a table number"
            sizes="(min-width: 1024px) 45vw, 92vw"
            className="aspect-[5/4] rounded-sm"
          />
        </ImageReveal>
        <Reveal className="lg:col-span-5 lg:col-start-8">
          <Eyebrow>Budget &amp; coordination</Eyebrow>
          <Display className="t-h3">The details, without the overwhelm.</Display>
          <Lead>Every cost and every payment date in view, so the numbers never become the story.</Lead>
          <Points
            items={[
              'Budget tracking by category, with payment schedules for each vendor',
              'A heads-up before payments fall due, and a clear flag if one is overdue',
              'Share access with a partner, planner or helper, each with the right permissions',
            ]}
          />
        </Reveal>
      </div>
    </section>
  );
}
