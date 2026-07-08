import { CheckCircle2, Users, FolderKanban, Brain } from "lucide-react";

const benefits = [
  {
    icon: Brain,
    text: "Know what matters next"
  },
  {
    icon: Users,
    text: "Keep guests organized"
  },
  {
    icon: FolderKanban,
    text: "Centralize every detail"
  },
  {
    icon: CheckCircle2,
    text: "Feel more in control"
  },
];

export function StressRelief() {
  return (
    <section className="py-20 lg:py-24" style={{ backgroundColor: "#EBD9CE" }}>
      <div className="mx-auto max-w-5xl px-6 lg:px-8">
        <div className="text-center space-y-6">
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
            Less chasing. Less forgetting.
            <br />
            Less overwhelm.
          </h2>

          <p
            className="mx-auto max-w-3xl text-[17px] sm:text-lg leading-relaxed"
            style={{
              color: "#5A524D",
              lineHeight: "1.65"
            }}
          >
            Udo is designed to reduce the invisible stress of wedding planning — the constant checking, reminding, searching, and second-guessing that can make the process feel heavier than it should. It gives you structure, visibility, and a calmer way to move through each stage.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-3.5 pt-2">
            {benefits.map((benefit, index) => {
              const Icon = benefit.icon;
              return (
                <div
                  key={index}
                  className="flex items-center gap-2.5 rounded-full px-4 py-2.5"
                  style={{
                    backgroundColor: "#ffffff",
                    border: "1.5px solid rgba(122, 94, 77, 0.15)",
                    boxShadow: "0 2px 6px rgba(122, 94, 77, 0.05)"
                  }}
                >
                  <Icon className="h-4 w-4" style={{ color: "#D8909A" }} />
                  <span
                    className="text-[14px]"
                    style={{
                      color: "#5A524D",
                      fontWeight: "450"
                    }}
                  >
                    {benefit.text}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}
