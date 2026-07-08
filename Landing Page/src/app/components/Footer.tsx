export function Footer() {
  return (
    <footer className="bg-white py-14 lg:py-16">
      <div className="mx-auto max-w-7xl px-6 lg:px-8">
        <div className="flex flex-col items-center justify-between gap-8 md:flex-row">
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

          {/* Links */}
          <nav className="flex flex-wrap items-center justify-center gap-8 text-[15px]">
            <a
              href="#about"
              className="transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              About
            </a>
            <a
              href="#contact"
              className="transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Contact
            </a>
            <a
              href="#privacy"
              className="transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Privacy
            </a>
            <a
              href="#terms"
              className="transition-colors hover:opacity-70"
              style={{
                color: "#5A524D",
                fontWeight: "450",
                letterSpacing: "0.01em"
              }}
            >
              Terms
            </a>
          </nav>
        </div>

        <div
          className="mt-10 border-t pt-7 text-center space-y-2"
          style={{ borderColor: "rgba(139, 111, 92, 0.12)" }}
        >
          <p
            className="text-sm"
            style={{
              color: "#6B625C",
              fontStyle: "italic"
            }}
          >
            Make your wedding day a peaceful one.
          </p>
          <p
            className="text-sm"
            style={{ color: "#6B625C" }}
          >
            © 2026 Udo. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
