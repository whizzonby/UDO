import { Header } from "./components/Header";
import { Hero } from "./components/Hero";
import { WhyUdo } from "./components/WhyUdo";
import { BuiltForSection } from "./components/BuiltForSection";
import { HowItWorks } from "./components/HowItWorks";
import { AppPreview } from "./components/AppPreview";
import { Features } from "./components/Features";
import { StressRelief } from "./components/StressRelief";
import { FullJourney } from "./components/FullJourney";
import { WeddingPageSection } from "./components/WeddingPageSection";
import { LookbookSection } from "./components/LookbookSection";
import { SmartCommunication } from "./components/SmartCommunication";
import { Pricing } from "./components/Pricing";
import { ProductPreview } from "./components/ProductPreview";
import { StartSteps } from "./components/StartSteps";
import { FinalCTA } from "./components/FinalCTA";
import { Footer } from "./components/Footer";

export default function App() {
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