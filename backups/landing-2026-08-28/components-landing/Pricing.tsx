import Link from 'next/link';
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";
import { PLAY_STORE_URL } from "@/lib/appLinks";

const freeFeatures = [
  "Up to 30 guests",
  "Guest portal & RSVP",
  "Task checklist & vision board",
  "Basic budget tracking",
  "3 vendors",
];

const passFeatures = [
  "Unlimited guests, vendors & messaging",
  "Full wedding setup",
  "Seating planner",
  "Budget tracking & payment schedules",
  "Wedding timeline",
  "Announcements & reminders",
  "Photo sharing",
  "Privacy controls",
  "Navigation tools",
];

export function Pricing() {
  return (
    <section id="pricing" className="py-20 lg:py-24" style={{ backgroundColor: "#FFF8F5" }}>
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-14 text-center space-y-3">
          <h2
            className="text-3xl sm:text-4xl lg:text-5xl"
            style={{
              color: "#2F4A3C",
              lineHeight: "1.2",
              fontWeight: "500",
              fontFamily: "var(--font-heading)",
              letterSpacing: "-0.01em"
            }}
          >
            Start free. Upgrade when you&apos;re ready.
          </h2>
          <p
            className="mx-auto max-w-2xl text-[17px] sm:text-lg"
            style={{
              color: "#5A524D",
              lineHeight: "1.6"
            }}
          >
            No subscriptions, ever. Plan for free with a small guest list, then unlock everything with one payment when the wedding gets real.
          </p>
        </div>

        <div className="mx-auto grid max-w-5xl gap-8 md:grid-cols-2">
          {/* Free plan */}
          <div className="flex flex-col rounded-3xl bg-white p-10 shadow-xl">
            <p
              className="text-sm uppercase tracking-wide"
              style={{ color: "#5A524D", fontWeight: "500" }}
            >
              Free
            </p>
            <div className="mt-4 flex items-baseline gap-2">
              <span className="text-6xl" style={{ color: "#2D2D2F", fontWeight: "500" }}>
                $0
              </span>
            </div>
            <p className="mt-2 text-sm" style={{ color: "#5A524D" }}>
              For trying Udo with a small planning circle.
            </p>

            <Button
              asChild
              size="lg"
              variant="outline"
              className="mt-6 w-full rounded-full py-6 text-base"
              style={{ borderColor: "#D8909A", color: "#D8909A" }}
            >
              <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer">Start Free</a>
            </Button>

            <div className="mt-8 space-y-3">
              {freeFeatures.map((feature, index) => (
                <div key={index} className="flex items-start gap-3">
                  <div
                    className="mt-0.5 flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full"
                    style={{ backgroundColor: "#D8909A30" }}
                  >
                    <Check className="h-3 w-3" style={{ color: "#D8909A" }} />
                  </div>
                  <span className="text-[15px]" style={{ color: "#5A524D" }}>
                    {feature}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Wedding Pass (lifetime) */}
          <div
            className="relative flex flex-col overflow-hidden rounded-3xl p-10 shadow-xl"
            style={{ backgroundColor: "#EBD9CE" }}
          >
            <div
              className="absolute right-6 top-6 rounded-full px-3 py-1 text-xs"
              style={{ backgroundColor: "#D8909A", color: "#ffffff", fontWeight: "500" }}
            >
              Most popular
            </div>
            <p
              className="text-sm uppercase tracking-wide"
              style={{ color: "#5A524D", fontWeight: "500" }}
            >
              Wedding Pass
            </p>
            <div className="mt-4 flex items-baseline gap-2">
              <span className="text-6xl" style={{ color: "#2D2D2F", fontWeight: "500" }}>
                $45
              </span>
            </div>
            <p className="mt-2 text-sm" style={{ color: "#5A524D" }}>
              One-time payment. No subscriptions, ever.
            </p>

            <Button
              asChild
              size="lg"
              className="mt-6 w-full rounded-full py-6 text-base shadow-md transition-all hover:shadow-lg hover:opacity-95"
              style={{ backgroundColor: "#D8909A", color: "#ffffff" }}
            >
              <Link href="/checkout">Get Wedding Pass</Link>
            </Button>

            <div className="mt-8 space-y-3">
              {passFeatures.map((feature, index) => (
                <div key={index} className="flex items-start gap-3">
                  <div
                    className="mt-0.5 flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full"
                    style={{ backgroundColor: "#ffffff80" }}
                  >
                    <Check className="h-3 w-3" style={{ color: "#2F4A3C" }} />
                  </div>
                  <span className="text-[15px]" style={{ color: "#5A524D" }}>
                    {feature}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Trust signals below */}
        <div className="mt-8 flex flex-wrap items-center justify-center gap-8 text-sm" style={{ color: "#8E8E93" }}>
          <div className="flex items-center gap-2">
            <Check className="h-4 w-4" style={{ color: "#E8A0A8" }} />
            <span>No monthly fees</span>
          </div>
          <div className="flex items-center gap-2">
            <Check className="h-4 w-4" style={{ color: "#E8A0A8" }} />
            <span>Start free, no card required</span>
          </div>
          <div className="flex items-center gap-2">
            <Check className="h-4 w-4" style={{ color: "#E8A0A8" }} />
            <span>Upgrade any time</span>
          </div>
        </div>
      </div>
    </section>
  );
}
