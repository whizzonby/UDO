import type { Metadata } from 'next';
import InviteWizard from '@/components/guest/InviteWizard';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

export async function generateMetadata({ params }: { params: { code: string } }): Promise<Metadata> {
  const description = "Enter your details to access your personal wedding experience.";
  let title = "You're Invited";

  try {
    const res = await fetch(`${API_BASE}/invite/${params.code}`, { next: { revalidate: 3600 } });
    if (res.ok) {
      const data = await res.json();
      const wedding = data.wedding;
      const couple = wedding.couple_name_secondary
        ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
        : wedding.couple_name_primary;
      if (couple) title = `${couple} — You're Invited`;
    }
  } catch {}

  return { title, description, openGraph: { title, description } };
}

export default function InvitePage({ params }: { params: { code: string } }) {
  return <InviteWizard code={params.code} />;
}
