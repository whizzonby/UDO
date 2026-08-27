import { SubPage } from '@/components/landing/SubPage';
import { WhyUdo } from '@/components/landing/WhyUdo';
import { HowItWorks } from '@/components/landing/HowItWorks';
import { BuiltForSection } from '@/components/landing/BuiltForSection';
import { StartSteps } from '@/components/landing/StartSteps';
import { StressRelief } from '@/components/landing/StressRelief';

export const metadata = {
  title: 'How Udo Works | Udo Weddings',
  description:
    'How Udo helps couples and planners move calmly from the first guest list to the last dance — set up your wedding, organize every detail, and share one guest link.',
};

export default function HowItWorksPage() {
  return (
    <SubPage
      eyebrow="How it works"
      title="Calm planning, start to finish"
      intro="Three simple moves take you from the first idea to a wedding day where everyone knows what's happening."
    >
      <WhyUdo />
      <HowItWorks />
      <BuiltForSection />
      <StartSteps />
      <StressRelief />
    </SubPage>
  );
}
