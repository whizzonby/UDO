import coupleHands from '@/public/landing/couple-hands.jpg';
import venueSwing from '@/public/landing/venue-swing.jpg';
import { Display, Eyebrow, Photo } from './Primitives';
import { ImageReveal, Reveal } from './Reveal';
import { color, container } from './tokens';

/** Section 8 — two audiences, two deliberately unequal compositions. */
export function Audiences() {
  return (
    <section aria-label="Who Udo is for">
      {/* Couples — ivory, photograph leads */}
      <div id="couples" className="scroll-mt-20" style={{ backgroundColor: color.ivory }}>
        <div className={`${container} grid items-center gap-12 py-20 sm:py-28 lg:grid-cols-12`}>
          <ImageReveal className="lg:col-span-5">
            <Photo
              src={coupleHands}
              alt="A bride and groom holding hands, her bouquet of pink flowers beside them"
              sizes="(min-width: 1024px) 38vw, 92vw"
              className="aspect-[4/5] rounded-t-[999px]"
              position="50% 45%"
            />
          </ImageReveal>
          <Reveal className="lg:col-span-6 lg:col-start-7">
            <Eyebrow>For couples</Eyebrow>
            <Display className="t-h3">Your wedding journey, beautifully in hand.</Display>
            <p className="t-lead mt-6 max-w-[32rem] leading-relaxed" style={{ color: color.body }}>
              Plan together with your partner from one shared space. Start with just your names and date, add the rest
              as it comes, and always know what&rsquo;s next.
            </p>
            <ul className="mt-8 grid max-w-[34rem] gap-x-8 sm:grid-cols-2">
              {['Shared with your partner', 'Free to start', 'Guests never need the app', 'Ready for the day itself'].map((t) => (
                <li key={t} className="border-t border-[#E2DBD0] py-4 text-[16px] font-medium" style={{ color: color.forest }}>
                  {t}
                </li>
              ))}
            </ul>
          </Reveal>
        </div>
      </div>

      {/* Planners — forest block, text leads, photograph inset */}
      <div id="planners" className="scroll-mt-20" style={{ backgroundColor: color.forest }}>
        <div className={`${container} grid items-center gap-12 py-20 sm:py-28 lg:grid-cols-12`}>
          <Reveal className="lg:col-span-6">
            <Eyebrow onDark>For planners</Eyebrow>
            <Display onDark className="t-h3">Bring every moving part into focus.</Display>
            <p className="t-lead mt-6 max-w-[32rem] leading-relaxed" style={{ color: color.blush }}>
              Couples invite you in, so you work from the same plan they do, with no separate spreadsheets to keep in
              sync.
            </p>
            <dl className="mt-8 max-w-[34rem]">
              {[
                ['Your own role', 'Join as planner or day-of coordinator, with access to exactly what that role needs.'],
                ['Every wedding you run', 'Switch between the wedding workspaces you’ve been invited to.'],
                ['The day itself', 'Live mode shows what’s now and next, with broadcasts and emergency contacts close.'],
              ].map(([t, d]) => (
                <div key={t} className="border-t py-5" style={{ borderColor: color.lineOnForest }}>
                  <dt className="text-[16px] font-semibold" style={{ color: color.ivory }}>
                    {t}
                  </dt>
                  <dd className="mt-1 text-[15.5px] leading-relaxed" style={{ color: color.blush }}>
                    {d}
                  </dd>
                </div>
              ))}
            </dl>
          </Reveal>
          <ImageReveal className="lg:col-span-5 lg:col-start-8">
            <Photo
              src={venueSwing}
              alt="A wedding venue lawn with a wooden swing hanging from a tree and rows of white chairs set for the ceremony"
              sizes="(min-width: 1024px) 38vw, 92vw"
              className="aspect-[5/6] rounded-sm"
            />
          </ImageReveal>
        </div>
      </div>
    </section>
  );
}

const ASSURANCES = [
  {
    title: 'Calm by design',
    body: 'One clear next step at a time, never a wall of overdue tasks.',
  },
  {
    title: 'Free to start',
    body: 'Plan with up to 30 guests at no cost, and upgrade only when you need more.',
  },
  {
    title: 'Easy for guests',
    body: 'Guests RSVP from a personal link. No downloads, no accounts, no passwords.',
  },
  {
    title: 'Your data, your call',
    body: 'Export your information from the app, and delete your account at any time, in the app or online.',
  },
] as const;

/** Section 9 — truthful reassurance (no testimonials until they're real). */
export function Reassurance() {
  return (
    <section aria-labelledby="reassure-title" className="py-20 sm:py-28" style={{ backgroundColor: color.cream }}>
      <div className={container}>
        <Reveal className="max-w-[40rem]">
          <Eyebrow>Peace of mind</Eyebrow>
          <Display id="reassure-title" className="t-h3">
            Built to make the months before your wedding feel lighter.
          </Display>
        </Reveal>
        <div className="mt-14 grid gap-x-12 sm:grid-cols-2 lg:grid-cols-4">
          {ASSURANCES.map((a, i) => (
            <Reveal key={a.title} delay={i * 0.06} className="border-t-2 border-[#C9BBA8] py-6">
              <div>
                <h3 className="font-display text-[26px] font-medium leading-tight" style={{ color: color.forest }}>
                  {a.title}
                </h3>
                <p className="mt-3 text-[16px] leading-relaxed" style={{ color: color.body }}>
                  {a.body}
                </p>
              </div>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
