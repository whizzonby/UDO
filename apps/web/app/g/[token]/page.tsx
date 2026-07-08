import GuestPortal from '@/components/guest/GuestPortal';

export default function GuestPortalPage({ params }: { params: { token: string } }) {
  return <GuestPortal token={params.token} />;
}
