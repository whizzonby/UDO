import { Heart, ClipboardList } from "lucide-react";

export function BuiltForSection() {
  return (
    <section className="bg-white py-20 lg:py-24">
      <div className="mx-auto max-w-6xl px-6 lg:px-8">
        <div className="mb-12 text-center">
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
            Built for Couples and Planners
          </h2>
        </div>

        <div className="grid gap-6 sm:grid-cols-2 lg:gap-8">
          {/* Couples Card */}
          <div
            className="rounded-3xl p-9 lg:p-10"
            style={{
              backgroundColor: "#FFF8F5",
              border: "1.5px solid rgba(216, 144, 154, 0.15)",
              boxShadow: "0 2px 12px rgba(232, 160, 168, 0.06)"
            }}
          >
            <div
              className="mb-5 inline-flex h-12 w-12 items-center justify-center rounded-2xl"
              style={{
                backgroundColor: "#D8909A"
              }}
            >
              <Heart className="h-5 w-5" style={{ color: "#ffffff" }} />
            </div>

            <h3
              className="mb-3 text-2xl"
              style={{
                color: "#2D2D2F",
                fontWeight: "500",
                fontFamily: "var(--font-heading)"
              }}
            >
              Couples
            </h3>

            <p
              className="text-[17px] leading-relaxed"
              style={{
                color: "#5A524D",
                lineHeight: "1.6"
              }}
            >
              Stay organized, reduce overwhelm, and keep every decision, guest detail, and important moment in one place.
            </p>
          </div>

          {/* Planners Card */}
          <div
            className="rounded-3xl p-9 lg:p-10"
            style={{
              backgroundColor: "#EBD9CE",
              border: "1.5px solid rgba(122, 94, 77, 0.15)",
              boxShadow: "0 2px 12px rgba(139, 111, 92, 0.08)"
            }}
          >
            <div
              className="mb-5 inline-flex h-12 w-12 items-center justify-center rounded-2xl"
              style={{
                backgroundColor: "#7A5E4D"
              }}
            >
              <ClipboardList className="h-5 w-5" style={{ color: "#ffffff" }} />
            </div>

            <h3
              className="mb-3 text-2xl"
              style={{
                color: "#2D2D2F",
                fontWeight: "500",
                fontFamily: "var(--font-heading)"
              }}
            >
              Planners
            </h3>

            <p
              className="text-[17px] leading-relaxed"
              style={{
                color: "#5A524D",
                lineHeight: "1.6"
              }}
            >
              Manage weddings with more structure, clearer client coordination, and a smoother planning flow from start to finish.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
