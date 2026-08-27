import { Button } from "@/components/ui/button";
import { Heart, Calendar, Users, Link2 } from "lucide-react";
import { PLAY_STORE_URL } from "@/lib/appLinks";

export function Hero() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-[#FFF8F5] via-[#FFF8F5] to-white">
      <div className="mx-auto max-w-7xl px-6 py-20 sm:py-28 lg:py-32 lg:px-8">
        <div className="grid items-center gap-14 lg:grid-cols-2 lg:gap-16">
          {/* Left Content */}
          <div className="space-y-8">
            <div className="space-y-6">
              <h1
                className="text-5xl tracking-tight sm:text-6xl lg:text-7xl"
                style={{
                  color: "#2D2D2F",
                  lineHeight: "1.08",
                  fontWeight: "500",
                  fontFamily: "var(--font-heading)"
                }}
              >
                Plan your wedding.
                <br />
                <span style={{ color: "#D8909A" }}>Keep your peace.</span>
              </h1>

              <p
                className="text-[17px]"
                style={{
                  color: "#6B625C",
                  lineHeight: "1.5",
                  fontWeight: "400",
                  letterSpacing: "0.01em"
                }}
              >
                A calm, intelligent wedding planning space for couples and planners.
              </p>

              <p
                className="max-w-xl text-lg sm:text-[19px]"
                style={{
                  color: "#5A524D",
                  lineHeight: "1.6",
                  fontWeight: "400"
                }}
              >
                Udo brings your guests, timeline, seating, budget, reminders, and wedding details into one beautifully organized place.
              </p>
            </div>

            {/* Value Strip */}
            <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2">
              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-full" style={{ backgroundColor: "#EBD9CE" }}>
                  <Calendar className="h-4 w-4" style={{ color: "#D8909A" }} />
                </div>
                <span className="text-[15px]" style={{ color: "#5A524D", fontWeight: "450" }}>
                  Know what to do next
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-full" style={{ backgroundColor: "#EBD9CE" }}>
                  <div className="h-4 w-4 rounded-sm" style={{ backgroundColor: "#D8909A" }} />
                </div>
                <span className="text-[15px]" style={{ color: "#5A524D", fontWeight: "450" }}>
                  Keep everything in one place
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-full" style={{ backgroundColor: "#EBD9CE" }}>
                  <Users className="h-4 w-4" style={{ color: "#D8909A" }} />
                </div>
                <span className="text-[15px]" style={{ color: "#5A524D", fontWeight: "450" }}>
                  Stay in control of guests
                </span>
              </div>

              <div className="flex items-center gap-2.5">
                <div className="flex h-8 w-8 items-center justify-center rounded-full" style={{ backgroundColor: "#EBD9CE" }}>
                  <Link2 className="h-4 w-4" style={{ color: "#D8909A" }} />
                </div>
                <span className="text-[15px]" style={{ color: "#5A524D", fontWeight: "450" }}>
                  Share one beautiful guest link
                </span>
              </div>
            </div>

            <div className="flex flex-col gap-3.5 sm:flex-row sm:gap-4">
              <Button
                asChild
                size="lg"
                className="rounded-full px-10 py-[26px] text-base font-medium tracking-wide shadow-md transition-all hover:shadow-lg hover:opacity-95"
                style={{
                  backgroundColor: "#D8909A",
                  color: "#ffffff",
                  letterSpacing: "0.02em"
                }}
              >
                <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer">
                  Get Udo on Google Play
                </a>
              </Button>
              <Button
                asChild
                size="lg"
                variant="outline"
                className="rounded-full px-10 py-[26px] text-base font-normal tracking-wide transition-all hover:bg-[#EBD9CE]"
                style={{
                  borderColor: "#7A5E4D",
                  borderWidth: "1.5px",
                  color: "#5A524D"
                }}
              >
                <a href="#how-it-works">See How It Works</a>
              </Button>
            </div>
          </div>

          {/* Right Visual */}
          <div className="relative lg:pl-8">
            <div className="relative">
              {/* Main Image */}
              <div 
                className="overflow-hidden rounded-3xl shadow-2xl"
                style={{ 
                  backgroundColor: "#F5E9E2",
                  boxShadow: "0 25px 50px -12px rgba(232, 160, 168, 0.25)"
                }}
              >
                <img 
                  src="https://images.unsplash.com/photo-1768900315637-146ae46a2fb9?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlbGVnYW50JTIwd2VkZGluZyUyMGNvdXBsZSUyMHBlYWNlZnVsfGVufDF8fHx8MTc3NDk5NjM3OHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Elegant wedding couple"
                  className="h-full w-full object-cover"
                />
              </div>

              {/* Floating Cards */}
              <div 
                className="absolute -left-6 top-20 rounded-2xl bg-white p-4 shadow-lg"
                style={{ borderLeft: "3px solid #E8A0A8" }}
              >
                <div className="flex items-center gap-3">
                  <div className="rounded-full p-2" style={{ backgroundColor: "#FFF8F5" }}>
                    <Users className="h-5 w-5" style={{ color: "#E8A0A8" }} />
                  </div>
                  <div>
                    <p className="text-xs" style={{ color: "#8E8E93" }}>Total Guests</p>
                    <p className="text-lg" style={{ color: "#1C1C1E", fontWeight: "500" }}>124</p>
                  </div>
                </div>
              </div>

              <div 
                className="absolute -right-4 bottom-24 rounded-2xl bg-white p-4 shadow-lg"
                style={{ borderLeft: "3px solid #CFAF7B" }}
              >
                <div className="flex items-center gap-3">
                  <div className="rounded-full p-2" style={{ backgroundColor: "#FFF8F5" }}>
                    <Heart className="h-5 w-5" style={{ color: "#CFAF7B" }} />
                  </div>
                  <div>
                    <p className="text-xs" style={{ color: "#8E8E93" }}>RSVPs</p>
                    <p className="text-lg" style={{ color: "#1C1C1E", fontWeight: "500" }}>98%</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}