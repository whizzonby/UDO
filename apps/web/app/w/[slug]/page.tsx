import WeddingPortalLanding from '@/components/guest/WeddingPortalLanding';

export default function WeddingPortalPage({ params }: { params: { slug: string } }) {
  return <WeddingPortalLanding slug={params.slug} />;
}
