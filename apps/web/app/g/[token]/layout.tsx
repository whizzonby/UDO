import Link from 'next/link';
import { Home, Calendar, Gift, Image, MessageCircle } from 'lucide-react';

export default async function GuestLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  const nav = [
    { href: `/g/${token}`,           icon: Home,          label: 'Home' },
    { href: `/g/${token}/schedule`,  icon: Calendar,      label: 'Schedule' },
    { href: `/g/${token}/registry`,  icon: Gift,          label: 'Registry' },
    { href: `/g/${token}/gallery`,   icon: Image,         label: 'Gallery' },
    { href: `/g/${token}/messages`,  icon: MessageCircle, label: 'Updates' },
  ];

  return (
    <div className="flex flex-col min-h-dvh">
      <main className="flex-1 pb-20">{children}</main>

      {/* Bottom navigation */}
      <nav className="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-[--color-udo-grey-200] safe-area-inset-bottom">
        <div className="flex items-stretch h-16 max-w-lg mx-auto">
          {nav.map(({ href, icon: Icon, label }) => (
            <Link
              key={href}
              href={href}
              className="flex-1 flex flex-col items-center justify-center gap-0.5 text-[--color-udo-grey-400] hover:text-[--color-udo-pink] transition-colors py-2"
            >
              <Icon size={20} strokeWidth={1.6} />
              <span className="text-[10px] font-medium tracking-wide">{label}</span>
            </Link>
          ))}
        </div>
      </nav>
    </div>
  );
}
