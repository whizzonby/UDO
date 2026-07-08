import { PenLine, Users, Link, Sparkles } from "lucide-react";

const steps = [
  {
    icon: PenLine,
    title: "Create your wedding"
  },
  {
    icon: Users,
    title: "Add your guests"
  },
  {
    icon: Link,
    title: "Share your link"
  },
  {
    icon: Sparkles,
    title: "Everything updates automatically"
  }
];

export function StartSteps() {
  return (
    <section className="bg-white py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h2 
            className="text-4xl sm:text-5xl"
            style={{ 
              color: "#1C1C1E",
              lineHeight: "1.2",
              fontWeight: "500"
            }}
          >
            Start in Minutes
          </h2>
        </div>

        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {steps.map((step, index) => {
            const Icon = step.icon;
            return (
              <div key={index} className="text-center">
                <div 
                  className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full"
                  style={{ backgroundColor: "#FFF8F5" }}
                >
                  <Icon className="h-10 w-10" style={{ color: "#E8A0A8" }} />
                </div>
                
                <p 
                  className="text-base"
                  style={{ color: "#8B6F5C", fontWeight: "500" }}
                >
                  {step.title}
                </p>

                {index < steps.length - 1 && (
                  <div className="mx-auto mt-6 hidden h-0.5 w-16 lg:block" style={{ backgroundColor: "#E8A0A820" }} />
                )}
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
