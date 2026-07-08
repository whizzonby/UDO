import Link from 'next/link';
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";

const features = [
  "Full wedding setup",
  "Guest & RSVP management",
  "Seating planner",
  "Budget tracking",
  "Wedding timeline",
  "Guest wedding page",
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
            One price. Everything you need.
          </h2>
          <p
            className="mx-auto max-w-2xl text-[17px] sm:text-lg"
            style={{
              color: "#5A524D",
              lineHeight: "1.6"
            }}
          >
            No subscriptions. No hidden fees. Just one calm, complete planning experience.
          </p>
        </div>

        <div className="mx-auto max-w-4xl">
          <div 
            className="overflow-hidden rounded-3xl shadow-xl"
            style={{ backgroundColor: "#ffffff" }}
          >
            <div className="grid lg:grid-cols-5">
              {/* Left Side - Price */}
              <div
                className="flex flex-col justify-center p-10 lg:col-span-2"
                style={{ backgroundColor: "#EBD9CE" }}
              >
                <div className="space-y-6">
                  <div>
                    <p
                      className="text-sm uppercase tracking-wide"
                      style={{ color: "#5A524D", fontWeight: "500" }}
                    >
                      Complete Package
                    </p>
                    <div className="mt-4 flex items-baseline gap-2">
                      <span
                        className="text-6xl"
                        style={{ color: "#2D2D2F", fontWeight: "500" }}
                      >
                        $45
                      </span>
                      <span
                        className="text-3xl"
                        style={{ color: "#6B625C" }}
                      >
                        .99
                      </span>
                    </div>
                    <p
                      className="mt-2 text-sm"
                      style={{ color: "#5A524D" }}
                    >
                      One-time payment
                    </p>
                  </div>

                  <p
                    className="text-base leading-relaxed"
                    style={{ color: "#6B625C" }}
                  >
                    Plan Your Wedding, Keep Your Peace
                  </p>

                  <Button
                    asChild
                    size="lg"
                    className="w-full rounded-full py-6 text-base shadow-md transition-all hover:shadow-lg hover:opacity-95"
                    style={{
                      backgroundColor: "#D8909A",
                      color: "#ffffff"
                    }}
                  >
                    <Link href="/register">Get Started Now</Link>
                  </Button>

                  <p
                    className="text-xs text-center"
                    style={{ color: "#6B625C" }}
                  >
                    Instant access • Lifetime updates
                  </p>
                </div>
              </div>

              {/* Right Side - Features */}
              <div className="p-10 lg:col-span-3">
                <div className="space-y-6">
                  <div>
                    <h3
                      className="mb-4 text-xl"
                      style={{ color: "#2D2D2F", fontWeight: "500" }}
                    >
                      What&apos;s included:
                    </h3>
                    <div className="space-y-3">
                      {features.map((feature, index) => (
                        <div key={index} className="flex items-start gap-3">
                          <div
                            className="mt-0.5 flex h-5 w-5 flex-shrink-0 items-center justify-center rounded-full"
                            style={{ backgroundColor: "#D8909A30" }}
                          >
                            <Check className="h-3 w-3" style={{ color: "#D8909A" }} />
                          </div>
                          <span
                            className="text-[15px]"
                            style={{ color: "#5A524D" }}
                          >
                            {feature}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Additional Note */}
                  <div
                    className="rounded-2xl p-6"
                    style={{ backgroundColor: "#EBD9CE" }}
                  >
                    <p
                      className="text-sm text-center leading-relaxed"
                      style={{
                        color: "#5A524D",
                        fontStyle: "italic"
                      }}
                    >
                      Built to replace scattered spreadsheets, notes, and endless message threads.
                    </p>
                  </div>
                </div>
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
              <span>Unlimited guests</span>
            </div>
            <div className="flex items-center gap-2">
              <Check className="h-4 w-4" style={{ color: "#E8A0A8" }} />
              <span>Lifetime access</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}