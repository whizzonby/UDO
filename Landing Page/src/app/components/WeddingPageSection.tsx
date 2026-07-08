import { CheckCircle2 } from "lucide-react";

const features = [
  "RSVP collection",
  "Guest contact details",
  "Dietary requirements",
  "Event details",
  "Contact phone number"
];

export function WeddingPageSection() {
  return (
    <section className="py-24" style={{ backgroundColor: "#FFF8F5" }}>
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="grid items-center gap-12 lg:grid-cols-2">
          {/* Left - Content */}
          <div className="space-y-6 lg:order-1">
            <h2 
              className="text-4xl sm:text-5xl"
              style={{ 
                color: "#1C1C1E",
                lineHeight: "1.2",
                fontWeight: "500"
              }}
            >
              Your Wedding,{" "}
              <span style={{ color: "#E8A0A8" }}>All in One Place</span>
            </h2>
            
            <p 
              className="text-lg leading-relaxed"
              style={{ color: "#8E8E93" }}
            >
              Create a beautiful in-app wedding page your guests can access anytime.
            </p>

            <div className="space-y-3 pt-4">
              {features.map((feature, index) => (
                <div key={index} className="flex items-center gap-3">
                  <CheckCircle2 className="h-5 w-5 flex-shrink-0" style={{ color: "#E8A0A8" }} />
                  <span 
                    className="text-base"
                    style={{ color: "#8B6F5C" }}
                  >
                    {feature}
                  </span>
                </div>
              ))}
            </div>

            <div 
              className="rounded-2xl p-6"
              style={{ backgroundColor: "#F5E9E2" }}
            >
              <p 
                className="text-base leading-relaxed"
                style={{ color: "#8B6F5C" }}
              >
                Guests receive a simple link to join and view your wedding details, RSVP, and stay updated — all within the app.
              </p>
            </div>
          </div>

          {/* Right - Mockup */}
          <div className="lg:order-2">
            <div 
              className="mx-auto max-w-sm overflow-hidden rounded-3xl shadow-2xl"
              style={{ 
                backgroundColor: "#ffffff",
                boxShadow: "0 25px 50px -12px rgba(232, 160, 168, 0.3)"
              }}
            >
              <div className="aspect-[9/16] overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1768900315637-146ae46a2fb9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVnYW50JTIwd2VkZGluZyUyMGNvdXBsZSUyMHBlYWNlZnVsfGVufDF8fHx8MTc3NDk5NjM3OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Wedding page in-app view"
                  className="h-full w-full object-cover"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
