import type { Metadata } from 'next';
import venueGarden from '@/public/landing/venue-garden.jpg';
import woodsWalk from '@/public/landing/woods-walk.jpg';
import { Shell, PageHeader, Display, Eyebrow, Reveal } from '@/components/landing/editorial/Shell';
import { DeepDives } from '@/components/landing/editorial/DeepDives';
import { Photo } from '@/components/landing/editorial/Primitives';
import { ImageReveal } from '@/components/landing/editorial/Reveal';
import { color, container } from '@/components/landing/editorial/tokens';

export const metadata: Metadata = {
  title: 'Features | Udo Wedding Planner',
  description:
    'Guest list and RSVPs, seating, budget and payment schedules, timeline, a guest wedding page, messaging, photo sharing, registry and a live wedding-day view, all in one wedding planning app.',
  alternates: { canonical: '/features' },
};

/** Further confirmed capabilities, presented as an editorial index (not cards). */
const MORE = [
  {
    title: 'A wedding page for guests',
    body: 'Share one link with your details, schedule and RSVP, so guests always have the latest without downloading anything.',
  },
  {
    title: 'Messages that reach everyone',
    body: 'Send announcements and updates by email, SMS or WhatsApp, with automatic nudges for anyone who hasn’t replied.',
  },
  {
    title: 'Photos and memories',
    body: 'Guests can add their photos to a shared gallery, so every angle of the day ends up in one place.',
  },
  {
    title: 'A registry that says thank you',
    body: 'Set up a cash fund and wishlist, then keep track of every gift and the thank-you notes still to send.',
  },
  {
    title: 'Live mode for the day itself',
    body: 'See what’s happening now and next, broadcast to guests and keep emergency contacts within reach.',
  },
  {
    title: 'An AI planning companion',
    body: 'Ask a planning question whenever you’re stuck and get a thoughtful suggestion for what to do next.',
  },
  {
    title: 'Vision and style',
    body: 'Gather inspiration into a vision board and shape the look and feel of your wedding.',
  },
  {
    title: 'Privacy you control',
    body: 'Decide what guests can see and share, and invite helpers with only the permissions they need.',
  },
] as const;

export default function FeaturesPage() {
  return (
    <Shell>
      <PageHeader
        eyebrow="Features"
        title="Everything your wedding needs, in one calm place."
        intro="From the first guest list to the last photo, Udo keeps every part of your wedding organized, shared with the people helping you, and easy to find."
        aside={
          <Photo
            src={venueGarden}
            alt="A glasshouse venue in a botanical garden, reflected in a still pond"
            sizes="(min-width: 1024px) 30vw, 92vw"
            priority
            className="aspect-[4/5] rounded-t-[999px]"
          />
        }
      />

      <DeepDives />

      <section aria-labelledby="more-title" className="py-20 sm:py-28" style={{ backgroundColor: color.cream }}>
        <div className={container}>
          <Reveal className="max-w-[44rem]">
            <Eyebrow>And there&rsquo;s more</Eyebrow>
            <Display id="more-title" className="t-h3">
              The small things that make the day run smoothly.
            </Display>
          </Reveal>
          <ol className="mt-14 grid gap-x-14 md:grid-cols-2">
            {MORE.map((m, i) => (
              <Reveal as="li" key={m.title} delay={(i % 2) * 0.06} className="flex gap-6 border-t border-[#D8CFC2] py-8">
                <span className="font-display w-10 shrink-0 text-[26px] font-medium tabular-nums" style={{ color: color.rose }} aria-hidden="true">
                  {String(i + 1).padStart(2, '0')}
                </span>
                <div>
                  <h3 className="font-display text-[28px] font-medium leading-tight" style={{ color: color.forest }}>
                    {m.title}
                  </h3>
                  <p className="mt-2 max-w-[28rem] text-[16px] leading-relaxed" style={{ color: color.body }}>
                    {m.body}
                  </p>
                </div>
              </Reveal>
            ))}
          </ol>
        </div>
      </section>

      <section aria-label="Built for the whole journey" style={{ backgroundColor: color.ivory }}>
        <div className={`${container} grid items-center gap-12 py-20 sm:py-28 lg:grid-cols-12`}>
          <ImageReveal className="lg:col-span-7">
            <Photo
              src={woodsWalk}
              alt="A bride and groom walking hand in hand along a leafy woodland path"
              sizes="(min-width: 1024px) 55vw, 92vw"
              className="aspect-[3/2] rounded-sm"
            />
          </ImageReveal>
          <Reveal className="lg:col-span-4 lg:col-start-9">
            <Display className="t-h3">From &ldquo;we&rsquo;re engaged&rdquo; to &ldquo;I do&rdquo;.</Display>
            <p className="t-lead mt-6 leading-relaxed" style={{ color: color.body }}>
              Planning, coordinating, telling your guests, the day itself and the memories afterwards: one app
              carries you through every stage.
            </p>
          </Reveal>
        </div>
      </section>
    </Shell>
  );
}
