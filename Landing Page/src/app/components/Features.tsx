import { Users, Grid3x3, DollarSign, Clock, Camera, Bell, MapPin, Shield, Link2 } from "lucide-react";

const features = [
  {
    icon: Users,
    title: "Guest & RSVP Management",
    description: "Track invitations, RSVPs, plus-ones, guest details, and meal selections in one place.",
    color: "#E8A0A8",
  },
  {
    icon: Grid3x3,
    title: "Seating & Floor Planning",
    description: "Organize guest placement with a clear seating planner that helps your day run more smoothly.",
    color: "#8B6F5C",
  },
  {
    icon: DollarSign,
    title: "Budget & Payment Tracking",
    description: "Keep your budget visible, track deposits and balances, and stay confident in your spending.",
    color: "#CFAF7B",
  },
  {
    icon: Clock,
    title: "Timeline & Wedding Day Schedule",
    description: "Build your full run of show so everyone knows where to be and when.",
    color: "#E8A0A8",
  },
  {
    icon: Link2,
    title: "Wedding Page for Guests",
    description: "Share one beautifully designed link with your event details, RSVP flow, updates, and key information.",
    color: "#8B6F5C",
  },
  {
    icon: Bell,
    title: "Announcements & Messaging",
    description: "Keep guests informed with reminders, updates, and changes without chasing messages.",
    color: "#CFAF7B",
  },
  {
    icon: Camera,
    title: "Photo & Memory Sharing",
    description: "Collect and organize memories in one elegant shared space.",
    color: "#E8A0A8",
  },
  {
    icon: Shield,
    title: "Privacy & Permissions",
    description: "Decide what guests can view, upload, or interact with.",
    color: "#8B6F5C",
  },
  {
    icon: MapPin,
    title: "Location & Navigation",
    description: "Help guests find venues, nearby stays, and important places with ease.",
    color: "#CFAF7B",
  },
];

export function Features() {
  return (
    <section id="features" className="bg-white py-20 lg:py-24">
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
            Everything You Need
          </h2>
          <p
            className="mx-auto max-w-2xl text-[17px] sm:text-lg"
            style={{
              color: "#5A524D",
              lineHeight: "1.6"
            }}
          >
            A complete wedding platform designed to reduce stress and create clarity
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <div
                key={index}
                className="group relative rounded-3xl p-7 lg:p-8 transition-all hover:shadow-md"
                style={{
                  backgroundColor: "#FFF8F5",
                  border: "1.5px solid rgba(139, 111, 92, 0.1)",
                  boxShadow: "0 2px 8px rgba(139, 111, 92, 0.03)"
                }}
              >
                <div className="space-y-4">
                  <div
                    className="inline-flex h-12 w-12 items-center justify-center rounded-2xl"
                    style={{ backgroundColor: `${feature.color}20` }}
                  >
                    <Icon className="h-5 w-5" style={{ color: feature.color }} />
                  </div>

                  <div className="space-y-2.5">
                    <h3
                      className="text-[18px]"
                      style={{
                        color: "#2D2D2F",
                        fontWeight: "500",
                        fontFamily: "var(--font-heading)",
                        lineHeight: "1.3"
                      }}
                    >
                      {feature.title}
                    </h3>

                    <p
                      className="text-[15px] leading-relaxed"
                      style={{
                        color: "#5A524D",
                        lineHeight: "1.6"
                      }}
                    >
                      {feature.description}
                    </p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}