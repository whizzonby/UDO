import { Image } from "lucide-react";

export function LookbookSection() {
  return (
    <section className="bg-white py-24">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="grid items-center gap-12 lg:grid-cols-2">
          {/* Left - Mockup */}
          <div>
            <div 
              className="mx-auto max-w-sm overflow-hidden rounded-3xl shadow-2xl"
              style={{ 
                backgroundColor: "#ffffff",
                boxShadow: "0 25px 50px -12px rgba(139, 111, 92, 0.3)"
              }}
            >
              <div className="aspect-[9/16] overflow-hidden">
                <img 
                  src="https://images.unsplash.com/photo-1771142480968-6036543055f7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxibHVzaCUyMHBpbmslMjByb3NlcyUyMHdlZGRpbmd8ZW58MXx8fHwxNzc0OTk2MzgxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Wedding lookbook inspiration"
                  className="h-full w-full object-cover"
                />
              </div>
            </div>
          </div>

          {/* Right - Content */}
          <div className="space-y-6">
            <div 
              className="inline-flex rounded-full p-3"
              style={{ backgroundColor: "#F5E9E2" }}
            >
              <Image className="h-6 w-6" style={{ color: "#8B6F5C" }} />
            </div>

            <h2 
              className="text-4xl sm:text-5xl"
              style={{ 
                color: "#1C1C1E",
                lineHeight: "1.2",
                fontWeight: "500"
              }}
            >
              Create Your{" "}
              <span style={{ color: "#8B6F5C" }}>Wedding Lookbook</span>
            </h2>
            
            <p 
              className="text-lg leading-relaxed"
              style={{ color: "#8E8E93" }}
            >
              Upload inspiration, themes, and visual ideas to keep your entire wedding aesthetic in one place.
            </p>

            <div 
              className="rounded-2xl p-6"
              style={{ backgroundColor: "#FFF8F5" }}
            >
              <p 
                className="text-sm leading-relaxed"
                style={{ color: "#8B6F5C" }}
              >
                Organize mood boards, color palettes, dress ideas, floral arrangements, and venue inspiration. Everything stays beautifully organized and easy to share with your partner or vendors.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
