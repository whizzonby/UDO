import { Sparkles, FolderKanban, Share2 } from "lucide-react";

const steps = [
  {
    icon: Sparkles,
    number: "1",
    title: "Create your wedding",
    description: "Set your date, guest count, event structure, and overall vision.",
    tag: "Personalized as you go"
  },
  {
    icon: FolderKanban,
    number: "2",
    title: "Organize everything in one place",
    description: "Manage guests, seating, budget, vendors, details, reminders, and your run of show.",
    tag: "Built around your day"
  },
  {
    icon: Share2,
    number: "3",
    title: "Share beautifully and stay aligned",
    description: "Send one elegant guest link, collect RSVPs, share updates, and keep everyone informed.",
    tag: "Calm communication"
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-20 lg:py-24" style={{ backgroundColor: "#FFF8F5" }}>
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
            How it works
          </h2>
          <p
            className="mx-auto max-w-2xl text-[17px] sm:text-lg"
            style={{
              color: "#5A524D",
              lineHeight: "1.6"
            }}
          >
            A calmer way to plan your wedding from start to finish
          </p>
        </div>

        <div className="mx-auto max-w-5xl">
          <div className="grid gap-6 md:grid-cols-3 lg:gap-7">
            {steps.map((step, index) => {
              const Icon = step.icon;
              return (
                <div
                  key={index}
                  className="relative rounded-3xl p-7 lg:p-8"
                  style={{
                    backgroundColor: "#ffffff",
                    border: "1.5px solid rgba(139, 111, 92, 0.12)",
                    boxShadow: "0 2px 10px rgba(139, 111, 92, 0.04)"
                  }}
                >
                  {/* Step Number */}
                  <div
                    className="absolute -top-3.5 left-7 flex h-9 w-9 items-center justify-center rounded-full text-base"
                    style={{
                      backgroundColor: "#D8909A",
                      color: "#ffffff",
                      fontWeight: "500",
                      fontFamily: "var(--font-heading)",
                      boxShadow: "0 2px 8px rgba(216, 144, 154, 0.2)"
                    }}
                  >
                    {step.number}
                  </div>

                  <div className="space-y-4 pt-3">
                    {/* Icon */}
                    <div
                      className="inline-flex h-11 w-11 items-center justify-center rounded-2xl"
                      style={{
                        backgroundColor: "#EBD9CE"
                      }}
                    >
                      <Icon className="h-5 w-5" style={{ color: "#D8909A" }} />
                    </div>

                    {/* Content */}
                    <div className="space-y-2.5">
                      <h3
                        className="text-xl"
                        style={{
                          color: "#2D2D2F",
                          fontWeight: "500",
                          fontFamily: "var(--font-heading)",
                          lineHeight: "1.3"
                        }}
                      >
                        {step.title}
                      </h3>
                      <p
                        className="text-[15px] leading-relaxed"
                        style={{
                          color: "#5A524D",
                          lineHeight: "1.6"
                        }}
                      >
                        {step.description}
                      </p>
                    </div>

                    {/* Tag */}
                    <div
                      className="inline-flex items-center rounded-full px-3 py-1.5 text-[13px]"
                      style={{
                        backgroundColor: "#EBD9CE",
                        color: "#5A524D",
                        fontWeight: "450"
                      }}
                    >
                      {step.tag}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}