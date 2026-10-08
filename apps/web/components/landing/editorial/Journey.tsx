import handsIndia from '@/public/landing/hands-india.jpg';
import sunsetPond from '@/public/landing/sunset-pond.jpg';
import { Display, Eyebrow, Photo } from './Primitives';
import { ImageReveal, Reveal } from './Reveal';
import { color, container } from './tokens';

const STEPS = [
  {
    n: '01',
    title: 'Make it yours',
    body: 'Add your names and your date. Udo sets up your wedding space in a minute, and everything else can wait until you’re ready.',
  },
  {
    n: '02',
    title: 'Bring every detail together',
    body: 'Build your guest list, track RSVPs, set your budget, map out your timeline and invite your partner or planner to help.',
  },
  {
    n: '03',
    title: 'Enjoy the journey',
    body: 'Each day Udo shows what matters next, and on the day itself Live mode keeps everyone on the same page.',
  },
] as const;

/** Section 5 — pinned photograph beside three large numbered steps. */
export function HowItWorks() {
  return (
    <section id="how-it-works" aria-labelledby="how-title" className="scroll-mt-20 py-20 sm:py-28 lg:py-36" style={{ backgroundColor: color.ivory }}>
      <div className={`${container} grid gap-14 lg:grid-cols-12 lg:gap-10`}>
        <div className="lg:col-span-5">
          <div className="lg:sticky lg:top-28">
            <Reveal>
              <Eyebrow>How Udo works</Eyebrow>
              <Display id="how-title" className="t-h2">
                Three gentle steps to a calmer wedding.
              </Display>
            </Reveal>
            <ImageReveal className="mt-10 hidden lg:block">
              <Photo
                src={handsIndia}
                alt="A groom in an ivory sherwani holding the hennaed hand of his bride in a red and gold lehenga"
                sizes="(min-width: 1024px) 38vw, 100vw"
                className="aspect-[4/5] rounded-sm"
                position="35% 50%"
              />
            </ImageReveal>
          </div>
        </div>

        <ol className="lg:col-span-6 lg:col-start-7">
          {STEPS.map((s, i) => (
            <Reveal as="li" key={s.n} delay={i * 0.05} className="border-t border-[#E2DBD0] py-10 first:border-t-0 first:pt-0 lg:py-16">
              <span className="font-display block text-[88px] font-medium leading-none sm:text-[120px]" style={{ color: color.rose }} aria-hidden="true">
                {s.n}
              </span>
              <h3 className="font-display mt-4 text-[34px] font-medium leading-tight sm:text-[40px]" style={{ color: color.forest }}>
                <span className="sr-only">Step {i + 1}: </span>
                {s.title}
              </h3>
              <p className="mt-4 max-w-[30rem] text-[17px] leading-relaxed" style={{ color: color.body }}>
                {s.body}
              </p>
            </Reveal>
          ))}
          <ImageReveal className="mt-4 lg:hidden">
            <Photo
              src={handsIndia}
              alt="A groom in an ivory sherwani holding the hennaed hand of his bride in a red and gold lehenga"
              sizes="100vw"
              className="aspect-[4/3] rounded-sm"
              position="35% 50%"
            />
          </ImageReveal>
        </ol>
      </div>
    </section>
  );
}

/** Section 6 — full-bleed photograph with a solid text panel (no overlay). */
export function Immersive() {
  return (
    <section aria-labelledby="immersive-title" className="relative" style={{ backgroundColor: color.forest }}>
      <div className="grid lg:min-h-[86svh] lg:grid-cols-12">
        <ImageReveal className="relative min-h-[62svh] lg:col-span-8 lg:min-h-0">
          <Photo
            src={sunsetPond}
            alt="A bride and groom sitting together on the grass by a pond at sunset, her head resting on his shoulder"
            sizes="(min-width: 1024px) 66vw, 100vw"
            className="absolute inset-0"
            position="50% 60%"
          />
        </ImageReveal>
        <div className="flex items-center lg:col-span-4">
          <Reveal className="px-6 py-16 sm:px-10 lg:px-12">
            <Eyebrow onDark>Why it matters</Eyebrow>
            <Display id="immersive-title" onDark className="t-h3">
              Less planning stress.
              <br />
              More room for the magic.
            </Display>
            <p className="mt-6 text-[17px] leading-relaxed" style={{ color: color.blush }}>
              When the lists, the numbers and the logistics live in one place, there&rsquo;s space again for what you
              actually want to remember: the two of you, and the people who came to celebrate.
            </p>
          </Reveal>
        </div>
      </div>
    </section>
  );
}
