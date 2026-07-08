import { Mail, Bell, Calendar } from "lucide-react";

const communicationFeatures = [
  {
    icon: Mail,
    title: "Email notifications",
    description: "Guests receive key updates via email"
  },
  {
    icon: Bell,
    title: "RSVP reminders",
    description: "Automatic reminders for pending RSVPs"
  },
  {
    icon: Calendar,
    title: "Schedule updates",
    description: "Instant notifications for any changes"
  }
];

export function SmartCommunication() {
  return (
    <section className="py-24" style={{ backgroundColor: "#FFF8F5" }}>
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
            Keep Everyone{" "}
            <span style={{ color: "#E8A0A8" }}>in the Loop</span>
          </h2>
          
          <p 
            className="mx-auto mt-4 max-w-2xl text-lg"
            style={{ color: "#8E8E93" }}
          >
            Send updates, reminders, and important information directly to your guests — without chasing messages.
          </p>
        </div>

        <div className="grid gap-8 md:grid-cols-3">
          {communicationFeatures.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <div 
                key={index}
                className="rounded-3xl bg-white p-8 text-center shadow-sm transition-all hover:shadow-md"
              >
                <div 
                  className="mx-auto mb-6 inline-flex rounded-full p-4"
                  style={{ backgroundColor: "#F5E9E2" }}
                >
                  <Icon className="h-8 w-8" style={{ color: "#E8A0A8" }} />
                </div>
                
                <h3 
                  className="mb-3 text-xl"
                  style={{ color: "#1C1C1E", fontWeight: "500" }}
                >
                  {feature.title}
                </h3>
                
                <p 
                  className="text-sm leading-relaxed"
                  style={{ color: "#8E8E93" }}
                >
                  {feature.description}
                </p>
              </div>
            );
          })}
        </div>

        <div 
          className="mx-auto mt-12 max-w-3xl rounded-3xl p-8 text-center"
          style={{ backgroundColor: "#F5E9E2" }}
        >
          <p 
            className="text-base leading-relaxed"
            style={{ color: "#8B6F5C" }}
          >
            Guests receive key updates via email, while everything stays organized inside the app.
          </p>
        </div>
      </div>
    </section>
  );
}
