import type { Metadata } from 'next';
import GuestPortal from '@/components/guest/GuestPortal';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

export async function generateMetadata({ params }: { params: { token: string } }): Promise<Metadata> {
  const description = 'View your invitation, RSVP, choose your meal and find all the details in one place.';
  let title = "You're Invited";

  try {
    const res = await fetch(`${API_BASE}/g/${params.token}`, { next: { revalidate: 3600 } });
    if (res.ok) {
      const data = await res.json();
      const wedding = data.wedding;
      const couple = wedding.couple_name_secondary
        ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
        : wedding.couple_name_primary;
      if (couple) title = `${couple} — You're Invited`;
    }
  } catch {
    // Keep the generic fallback title/description below.
  }

  return {
    title,
    description,
    openGraph: { title, description },
  };
}

export default function GuestPortalPage({ params }: { params: { token: string } }) {
  return <GuestPortal token={params.token} />;
}
