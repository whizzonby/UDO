'use client';

import { useRouter } from 'next/navigation';
import MorePage from '@/components/dashboard/MorePage';

export default function MoreDashboardPage() {
  const router = useRouter();

  const handleNavigate = (tab: string) => {
    router.push(`/dashboard/${tab}`);
  };

  return <MorePage onNavigate={handleNavigate} />;
}
