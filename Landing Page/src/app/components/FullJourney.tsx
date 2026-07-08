import { PenTool, Calendar, MessageCircle, CheckSquare, Camera } from "lucide-react";

const stages = [
  {
    icon: PenTool,
    label: "Planning"
  },
  {
    icon: Calendar,
    label: "Coordination"
  },
  {
    icon: MessageCircle,
    label: "Communication"
  },
  {
    icon: CheckSquare,
    label: "Execution"
  },
  {
    icon: Camera,
    label: "Memory Keeping"
  },
];

export function FullJourney() {
  return (
    <section className="py-20 lg:py-24" style={{ backgroundColor: "#ffffff" }}>
      <div className="mx-auto max-w-6xl px-6 lg:px-8">
        <div className="text-center space-y-6 mb-12">
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
            Designed for the full journey
          </h2>

          <p
            className="mx-auto max-w-3xl text-[17px] sm:text-lg leading-relaxed"
            style={{
              color: "#5A524D",
              lineHeight: "1.6"
            }}
          >
            From the first guest list to your final schedule and shared memories, Udo helps you stay organized through every stage.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-5 sm:grid-cols-3 md:grid-cols-5 md:gap-6">
          {stages.map((stage, index) => {
            const Icon = stage.icon;
            return (
              <div
                key={index}
                className="flex flex-col items-center gap-3.5 rounded-3xl p-6 lg:p-7"
                style={{
                  backgroundColor: "#FFF8F5",
                  border: "1.5px solid rgba(139, 111, 92, 0.15)",
                  boxShadow: "0 2px 8px rgba(139, 111, 92, 0.05)"
                }}
              >
                <div
                  className="flex h-12 w-12 items-center justify-center rounded-2xl"
                  style={{
                    backgroundColor: "#D8909A"
                  }}
                >
                  <Icon className="h-5 w-5" style={{ color: "#ffffff" }} />
                </div>

                <span
                  className="text-center text-[15px]"
                  style={{
                    color: "#2D2D2F",
                    fontWeight: "500"
                  }}
                >
                  {stage.label}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
