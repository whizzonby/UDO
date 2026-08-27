import { PLAY_STORE_URL } from "@/lib/appLinks";

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

        {/* App store badges */}
        <div className="mt-10 flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
          <div
            aria-label="Download on the App Store — coming soon"
            className="flex items-center gap-3 rounded-xl border border-black/30 px-5 py-3 opacity-50"
            style={{ minWidth: 160 }}
          >
            {/* Apple logo */}
            <svg width="22" height="26" viewBox="0 0 22 26" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
              <path d="M18.07 13.77c-.03-3.04 2.48-4.51 2.59-4.58-1.41-2.06-3.61-2.35-4.39-2.38-1.87-.19-3.66 1.1-4.61 1.1-.96 0-2.44-1.08-4.01-1.05-2.06.03-3.97 1.2-5.02 3.04-2.15 3.72-.55 9.22 1.54 12.24 1.03 1.48 2.25 3.14 3.85 3.08 1.55-.06 2.13-.99 4.01-.99 1.87 0 2.4.99 4.03.96 1.66-.03 2.72-1.51 3.74-3 1.18-1.72 1.67-3.39 1.7-3.47-.04-.02-3.42-1.31-3.45-5.22l.02.27zM14.96 4.56c.86-1.04 1.44-2.48 1.28-3.92-1.24.05-2.74.83-3.63 1.87-.8.92-1.5 2.4-1.31 3.81 1.38.11 2.79-.7 3.66-1.76z" fill="#000"/>
            </svg>
            <div className="flex flex-col leading-none">
              <span className="text-[10px] text-black" style={{ fontWeight: 400 }}>iOS app</span>
              <span className="text-[17px] text-black" style={{ fontWeight: 600, letterSpacing: '-0.3px' }}>Coming soon</span>
            </div>
          </div>

          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Get it on Google Play"
            className="flex items-center gap-3 rounded-xl border border-black px-5 py-3 transition-opacity hover:opacity-75"
            style={{ minWidth: 160 }}
          >
            {/* Google Play triangle logo */}
            <svg width="22" height="24" viewBox="0 0 22 24" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
              <path d="M0.43 0.22C0.16 0.51 0 0.96 0 1.54v20.92c0 .58.16 1.03.44 1.32l.07.07 11.72-11.72v-.28L0.5.15.43.22z" fill="url(#gp1)"/>
              <path d="M16.07 15.97l-3.9-3.9v-.28l3.9-3.9.09.05 4.62 2.62c1.32.75 1.32 1.98 0 2.73l-4.62 2.62-.09.06z" fill="url(#gp2)"/>
              <path d="M16.16 15.91L12.17 12 .43 23.74c.43.46 1.15.52 1.96.06l13.77-7.89" fill="url(#gp3)"/>
              <path d="M16.16 8.09L2.39.2C1.58-.26.86-.2.43.26L12.17 12l4-3.91z" fill="url(#gp4)"/>
              <defs>
                <linearGradient id="gp1" x1="11.11" y1="1.46" x2="-4.9" y2="17.47" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#00A0FF"/>
                  <stop offset="0.007" stopColor="#00A1FF"/>
                  <stop offset="0.26" stopColor="#00BEFF"/>
                  <stop offset="0.512" stopColor="#00D2FF"/>
                  <stop offset="0.76" stopColor="#00DFFF"/>
                  <stop offset="1" stopColor="#00E3FF"/>
                </linearGradient>
                <linearGradient id="gp2" x1="21.8" y1="12" x2="-.28" y2="12" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FFE000"/>
                  <stop offset="0.409" stopColor="#FFBD00"/>
                  <stop offset="0.775" stopColor="#FFA500"/>
                  <stop offset="1" stopColor="#FF9C00"/>
                </linearGradient>
                <linearGradient id="gp3" x1="13.78" y1="13.95" x2="-6.9" y2="34.63" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#FF3A44"/>
                  <stop offset="1" stopColor="#C31162"/>
                </linearGradient>
                <linearGradient id="gp4" x1="-1.98" y1="-6.29" x2="7.29" y2="2.98" gradientUnits="userSpaceOnUse">
                  <stop stopColor="#32A071"/>
                  <stop offset="0.069" stopColor="#2DA771"/>
                  <stop offset="0.476" stopColor="#15CF74"/>
                  <stop offset="0.801" stopColor="#06E775"/>
                  <stop offset="1" stopColor="#00F076"/>
                </linearGradient>
              </defs>
            </svg>
            <div className="flex flex-col leading-none">
              <span className="text-[10px] text-black" style={{ fontWeight: 400 }}>Get it on</span>
              <span className="text-[17px] text-black" style={{ fontWeight: 600, letterSpacing: '-0.3px' }}>Google Play</span>
            </div>
          </a>
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
