import Script from 'next/script';

// GA4 measurement ID. Override per-environment with NEXT_PUBLIC_GA_ID;
// set it to "" to disable analytics (e.g. staging).
const GA_ID = process.env.NEXT_PUBLIC_GA_ID ?? 'G-V4VF9GMPYJ';

export function GoogleAnalytics() {
  if (!GA_ID) return null;

  return (
    <>
      <Script
        src={`https://www.googletagmanager.com/gtag/js?id=${GA_ID}`}
        strategy="afterInteractive"
      />
      <Script id="ga-init" strategy="afterInteractive">
        {`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', '${GA_ID}');
        `}
      </Script>
    </>
  );
}
