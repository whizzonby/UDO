import { Header } from './Header';
import { Hero } from './Hero';
import { WhyUdo } from './WhyUdo';
import { BuiltForSection } from './BuiltForSection';
import { HowItWorks } from './HowItWorks';
import { AppPreview } from './AppPreview';
import { Features } from './Features';
import { StressRelief } from './StressRelief';
import { FullJourney } from './FullJourney';
import { WeddingPageSection } from './WeddingPageSection';
import { LookbookSection } from './LookbookSection';
import { SmartCommunication } from './SmartCommunication';
import { Pricing } from './Pricing';
import { ProductPreview } from './ProductPreview';
import { StartSteps } from './StartSteps';
import { FinalCTA } from './FinalCTA';
import { Footer } from './Footer';

export default function LandingPage() {
  return (
    <div className="min-h-screen">
      <Header />
      <Hero />
      <WhyUdo />
      <BuiltForSection />
      <HowItWorks />
      <AppPreview />
      <Features />
      <StressRelief />
      <FullJourney />
      <WeddingPageSection />
      <LookbookSection />
      <SmartCommunication />
      <Pricing />
      <ProductPreview />
      <StartSteps />
      <FinalCTA />
      <Footer />
    </div>
  );
}
