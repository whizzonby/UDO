import type { Metadata } from 'next';
import { PLAY_STORE_URL } from '@/lib/appLinks';
import { Shell } from '@/components/landing/editorial/Shell';
import { Hero } from '@/components/landing/editorial/Hero';
import { Showcase, Statement } from '@/components/landing/editorial/Story';
import { HowItWorks, Immersive } from '@/components/landing/editorial/Journey';
import { DeepDives } from '@/components/landing/editorial/DeepDives';
import { Audiences, Reassurance } from '@/components/landing/editorial/Audiences';
import { Faq } from '@/components/landing/editorial/Faq';
import { FAQS } from '@/components/landing/editorial/faqData';

const SITE = 'https://udowedding.com';
const TITLE = 'Udo — The Calm Wedding Planner App';
const DESCRIPTION =
  'Plan your wedding beautifully with Udo: guest list and RSVPs, wedding budget, checklist, timeline and a live wedding-day view, all in one calm wedding planning app.';

export const metadata: Metadata = {
  metadataBase: new URL(SITE),
  title: TITLE,
  description: DESCRIPTION,
  alternates: { canonical: '/' },
  openGraph: {
    type: 'website',
    url: SITE,
    siteName: 'Udo',
    title: TITLE,
    description: DESCRIPTION,
    images: [{ url: '/landing/og.jpg', width: 1200, height: 630, alt: 'An outdoor wedding aisle lined with blush roses, with the Udo app' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: TITLE,
    description: DESCRIPTION,
    images: ['/landing/og.jpg'],
  },
};

const structuredData = [
  {
    '@context': 'https://schema.org',
    '@type': 'MobileApplication',
    name: 'Udo',
    operatingSystem: 'ANDROID',
    applicationCategory: 'LifestyleApplication',
    description: DESCRIPTION,
    url: SITE,
    installUrl: PLAY_STORE_URL,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    publisher: { '@type': 'Organization', name: 'WHIZZONBY LTD', email: 'hello@udowedding.com' },
  },
  {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: FAQS.map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  },
];

export default function HomePage() {
  return (
    <Shell>
      <Hero />
      <Statement />
      <Showcase />
      <HowItWorks />
      <Immersive />
      <DeepDives />
      <Audiences />
      <Reassurance />
      <Faq />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }} />
    </Shell>
  );
}
