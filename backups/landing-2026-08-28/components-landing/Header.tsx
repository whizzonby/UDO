import Link from 'next/link';
import { Button } from "@/components/ui/button";
import { PLAY_STORE_URL } from "@/lib/appLinks";

export function Header() {
  return (
    <header
      className="sticky top-0 z-50 border-b backdrop-blur-md"
      style={{
        backgroundColor: "rgba(255, 248, 245, 0.95)",
        borderColor: "rgba(139, 111, 92, 0.08)"
      }}
    >
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex h-[72px] items-center justify-between">
          {/* Logo */}
          <div className="flex items-center gap-3.5">
            <div
              className="flex h-10 w-10 items-center justify-center rounded-full"
              style={{
                background: "linear-gradient(135deg, #E8A0A8 0%, #D8909A 100%)",
                boxShadow: "0 2px 8px rgba(232, 160, 168, 0.15)"
              }}
            >
              <span
                className="text-base"
                style={{
                  color: "#ffffff",
                  fontWeight: "600",
                  fontFamily: "var(--font-heading)",
                  letterSpacing: "0.01em"
                }}
              >
                U
              </span>
            </div>
            <span
              className="text-[26px] tracking-wide"
              style={{
                color: "#2D2D2F",
                fontWeight: "500",
                fontFamily: "var(--font-heading)",
                letterSpacing: "0.04em"
              }}
            >
              Udo
            </span>
          </div>

          {/* Navigation */}
          <nav className="hidden items-center gap-10 md:flex">
            <a
              href="#features"
              className="text-[15px] transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Features
            </a>
            <a
              href="#how-it-works"
              className="text-[15px] transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              How It Works
            </a>
            <a
              href="#pricing"
              className="text-[15px] transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Pricing
            </a>
            <Link
              href="/login"
              className="text-[15px] transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Sign in
            </Link>
            <Button
              asChild
              className="rounded-full px-7 py-5 text-[15px] font-medium tracking-wide transition-all hover:shadow-lg hover:opacity-95"
              style={{
                backgroundColor: "#E8A0A8",
                color: "#ffffff",
                letterSpacing: "0.02em"
              }}
            >
              <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer">Get the App</a>
            </Button>
          </nav>

          {/* Mobile menu button */}
          <div className="flex items-center gap-3 md:hidden">
            <Link
              href="/login"
              className="text-sm transition-colors hover:opacity-70"
              style={{ color: "#5A524D", fontWeight: "450" }}
            >
              Sign in
            </Link>
            <Button
              asChild
              className="rounded-full px-6 py-5 text-sm"
              style={{
                backgroundColor: "#E8A0A8",
                color: "#ffffff"
              }}
            >
              <a href={PLAY_STORE_URL} target="_blank" rel="noopener noreferrer">Get the App</a>
            </Button>
          </div>
        </div>
      </div>
    </header>
  );
}
