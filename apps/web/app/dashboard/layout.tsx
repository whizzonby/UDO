'use client';

import { useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { Home, Calendar, Users, Radio, Image, MoreHorizontal } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { WeddingProvider } from '@/contexts/WeddingContext';

const tabs = [
  { href: '/dashboard/home', label: 'Home', icon: Home },
  { href: '/dashboard/plan', label: 'Plan', icon: Calendar },
  { href: '/dashboard/guests', label: 'Guests', icon: Users },
  { href: '/dashboard/live', label: 'Live', icon: Radio },
  { href: '/dashboard/gallery', label: 'Gallery', icon: Image },
  { href: '/dashboard/more', label: 'More', icon: MoreHorizontal },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace('/login');
    }
  }, [user, isLoading, router]);

  if (isLoading) {
    return (
      <div className="h-screen flex items-center justify-center bg-white">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!user) return null;

  return (
    <WeddingProvider>
    <div className="h-screen flex flex-col bg-white overflow-hidden max-w-md mx-auto relative">
      <div className="flex-1 overflow-y-auto pb-20">
        {children}
      </div>

      {/* Bottom navigation */}
      <div className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md bg-white border-t border-gray-200 shadow-[0_-4px_12px_rgba(0,0,0,0.05)] z-50">
        <div className="flex justify-around items-center px-2 py-2">
          {tabs.map(({ href, label, icon: Icon }) => {
            const isActive = pathname.startsWith(href);
            return (
              <Link
                key={href}
                href={href}
                className="flex flex-col items-center justify-center flex-1 py-2 px-1 transition-all duration-200"
              >
                <Icon
                  className={`mb-1 transition-colors ${isActive ? 'text-[#FF3E9B]' : 'text-gray-400'}`}
                  size={22}
                  strokeWidth={isActive ? 2.5 : 2}
                />
                <span className={`text-[10px] transition-colors ${isActive ? 'text-[#FF3E9B] font-medium' : 'text-gray-500'}`}>
                  {label}
                </span>
              </Link>
            );
          })}
        </div>
      </div>
    </div>
    </WeddingProvider>
  );
}
