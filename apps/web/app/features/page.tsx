import { SubPage } from '@/components/landing/SubPage';
import { Features } from '@/components/landing/Features';
import { FullJourney } from '@/components/landing/FullJourney';
import { WeddingPageSection } from '@/components/landing/WeddingPageSection';
import { SmartCommunication } from '@/components/landing/SmartCommunication';
import { LookbookSection } from '@/components/landing/LookbookSection';
import { AppPreview } from '@/components/landing/AppPreview';

export const metadata = {
  title: 'Features | Udo Weddings',
  description:
    'Guests and RSVPs, seating, budget, timeline, a guest wedding page, announcements, photo sharing, and more — everything the wedding needs in one app.',
};

export default function FeaturesPage() {
  return (
    <SubPage
      eyebrow="Features"
      title="Everything the wedding needs, in one app"
      intro="From the guest list to the seating chart to the photos afterward, Udo keeps every part of the day in one calm place."
    >
      <Features />
      <FullJourney />
      <WeddingPageSection />
      <SmartCommunication />
      <LookbookSection />
      <AppPreview />
    </SubPage>
  );
}
