'use client';

import { useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import { LayoutDashboard, ListChecks, Image as ImageIcon, User, CreditCard, LogOut, Heart } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { WeddingProvider } from '@/contexts/WeddingContext';

const tabs = [
  { href: '/dashboard/home', label: 'Overview', icon: LayoutDashboard },
  { href: '/dashboard/tasks', label: 'Tasks', icon: ListChecks },
  { href: '/dashboard/gallery', label: 'Gallery', icon: ImageIcon },
  { href: '/dashboard/account', label: 'Account', icon: User },
  { href: '/dashboard/billing', label: 'Billing', icon: CreditCard },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading, logout } = useAuth();
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
      <div className="min-h-screen bg-[#FAFAF8]">
        <header className="bg-white border-b border-gray-200">
          <div className="mx-auto max-w-6xl px-6 flex items-center justify-between h-16">
            <Link href="/dashboard/home" className="flex items-center gap-2">
              <Heart className="text-[#D8909A]" size={20} fill="#D8909A" />
              <span className="font-medium text-[#2F4A3C]">Udo</span>
            </Link>
            <nav className="hidden sm:flex items-center gap-1">
              {tabs.map(({ href, label, icon: Icon }) => {
                const isActive = pathname.startsWith(href);
                return (
                  <Link
                    key={href}
                    href={href}
                    className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                      isActive ? 'bg-[#285301]/10 text-[#285301]' : 'text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    <Icon size={16} />
                    {label}
                  </Link>
                );
              })}
            </nav>
            <button
              onClick={logout}
              className="flex items-center gap-1.5 text-sm text-gray-400 hover:text-gray-600"
            >
              <LogOut size={16} />
              <span className="hidden sm:inline">Log out</span>
            </button>
          </div>
          {/* Mobile nav */}
          <nav className="sm:hidden flex items-center gap-1 overflow-x-auto px-4 pb-3">
            {tabs.map(({ href, label, icon: Icon }) => {
              const isActive = pathname.startsWith(href);
              return (
                <Link
                  key={href}
                  href={href}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium whitespace-nowrap ${
                    isActive ? 'bg-[#285301]/10 text-[#285301]' : 'text-gray-500'
                  }`}
                >
                  <Icon size={14} />
                  {label}
                </Link>
              );
            })}
          </nav>
        </header>
        <main className="mx-auto max-w-6xl px-6 py-8">{children}</main>
      </div>
    </WeddingProvider>
  );
}
