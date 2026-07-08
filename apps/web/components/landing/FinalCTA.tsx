import Link from 'next/link';
import { Button } from "@/components/ui/button";

export function FinalCTA() {
  return (
    <section
      className="py-20 lg:py-24"
      style={{ backgroundColor: "#D8909A" }}
    >
      <div className="mx-auto max-w-4xl px-6 text-center lg:px-8">
        <div className="space-y-7">
          <h2
            className="text-4xl sm:text-5xl lg:text-6xl"
            style={{
              color: "#ffffff",
              lineHeight: "1.1",
              fontWeight: "500",
              fontFamily: "var(--font-heading)"
            }}
          >
            Plan your wedding.
            <br />
            Keep your peace.
          </h2>

          <p
            className="mx-auto max-w-2xl text-[18px] sm:text-xl"
            style={{
              color: "rgba(255, 255, 255, 0.95)",
              lineHeight: "1.6"
            }}
          >
            Everything you need, thoughtfully organized in one place.
          </p>

          <div className="flex flex-col items-center gap-5">
            <Button
              asChild
              size="lg"
              className="rounded-full px-10 py-[26px] text-base font-medium tracking-wide shadow-lg transition-all hover:shadow-xl hover:opacity-95"
              style={{
                backgroundColor: "#ffffff",
                color: "#D8909A",
                letterSpacing: "0.02em"
              }}
            >
              <Link href="/register">Create Your Wedding</Link>
            </Button>

            <p
              className="text-sm"
              style={{
                color: "rgba(255, 255, 255, 0.85)"
              }}
            >
              Start in minutes. Stay organized all the way through.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}