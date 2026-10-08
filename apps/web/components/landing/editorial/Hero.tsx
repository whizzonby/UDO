import heroAisle from '@/public/landing/hero-aisle.jpg';
import appHome from '@/public/landing/app-home.jpg';
import { Display, Phone, Photo, StoreButtons } from './Primitives';
import { color, container } from './tokens';

export function Hero() {
  return (
    <section aria-labelledby="hero-title" className="relative overflow-hidden pt-[68px]" style={{ backgroundColor: color.ivory }}>
      <div className={`${container} grid items-center gap-12 pb-16 pt-10 lg:min-h-[min(calc(100svh-68px),900px)] lg:grid-cols-12 lg:gap-8 lg:pb-20 lg:pt-6`}>
        {/* Copy */}
        <div className="lg:col-span-6 lg:pr-6">
          <p className="rise mb-6 flex items-center gap-3 text-[12px] font-semibold uppercase tracking-[0.24em]" style={{ color: color.champagneDeep }}>
            <span className="h-px w-8" style={{ backgroundColor: color.rose }} aria-hidden="true" />
            The calm wedding planner
          </p>
          <Display as="h1" id="hero-title" className="t-hero rise rise-1">
            Your wedding,
            <br />
            <span style={{ color: color.roseDeep }}>beautifully</span> planned.
          </Display>
          <p className="t-lead rise rise-2 mt-7 max-w-[30rem] leading-relaxed" style={{ color: color.body }}>
            From the first idea to the final celebration, Udo brings every detail together, so you can spend less
            time worrying and more time enjoying the journey.
          </p>

          <div className="rise rise-3 mt-9">
            <p className="mb-3 text-[13px] font-semibold" style={{ color: color.forest }}>
              Start planning with Udo
            </p>
            <StoreButtons placement="hero" />
            <a
              href="#experience"
              data-track="explore-experience"
              className="mt-6 inline-flex items-center gap-2 text-[15px] font-semibold underline decoration-1 underline-offset-[7px]"
              style={{ color: color.forest, textDecorationColor: color.rose }}
            >
              Explore the experience
              <span aria-hidden="true">↓</span>
            </a>
          </div>
        </div>

        {/* Art-directed composition: ceremony photograph + real app screen */}
        <div className="relative lg:col-span-6">
          <div className="rise rise-1 relative ml-auto w-[86%] sm:w-[78%] lg:w-[90%]">
            <Photo
              src={heroAisle}
              alt="An outdoor wedding aisle lined with wooden chairs and blush rose arrangements leading to a white floral arch"
              sizes="(min-width: 1024px) 55vw, 88vw"
              priority
              position="50% 40%"
              className="aspect-[4/5] rounded-t-[999px] lg:aspect-[5/6]"
            />
          </div>
          <div className="rise rise-3 absolute bottom-[-6%] left-0 w-[44%] max-w-[250px] sm:w-[36%] lg:bottom-[4%] lg:left-[-4%] lg:w-[40%]">
            <Phone
              src={appHome}
              alt="The Udo app home screen showing a wedding countdown, 206 days until forever, and today's planning focus"
              priority
              sizes="(min-width: 1024px) 260px, 44vw"
            />
          </div>
        </div>
      </div>
    </section>
  );
}
