import { SubPage } from '@/components/landing/SubPage';
import { Pricing } from '@/components/landing/Pricing';

export const metadata = {
  title: 'Pricing | Udo Weddings',
  description:
    'Plan for free with a small guest list, then unlock everything with one payment. No subscriptions, ever.',
};

export default function PricingPage() {
  return (
    <SubPage
      eyebrow="Pricing"
      title="Start free. Pay once when it gets real."
      intro="No subscriptions, no monthly fees. Try Udo free, then unlock everything with a single payment."
    >
      <Pricing />
    </SubPage>
  );
}
