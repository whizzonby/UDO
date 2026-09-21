import { SubPage } from '@/components/landing/SubPage';
import { Pricing } from '@/components/landing/Pricing';

export const metadata = {
  title: 'Pricing | Udo Weddings',
  description:
    'Plan for free with a small guest list, then unlock everything for $4.99/month or a single $49.99 payment.',
};

export default function PricingPage() {
  return (
    <SubPage
      eyebrow="Pricing"
      title="Start free. Upgrade when it gets real."
      intro="Try Udo free. Then unlock everything with Udo Premium at $4.99/month, or pay once for the Wedding Pass."
    >
      <Pricing />
    </SubPage>
  );
}
