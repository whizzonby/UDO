'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, Heart } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';

const features = [
  'Full wedding setup',
  'Guest & RSVP management',
  'Seating planner',
  'Budget tracking',
  'Wedding timeline',
  'Guest wedding page',
  'Announcements & reminders',
  'Photo sharing',
  'Privacy controls',
  'Navigation tools',
];

export default function CheckoutPage() {
  const { user, token, isLoading } = useAuth();
  const router = useRouter();
  const [starting, setStarting] = useState(false);
  const [configured, setConfigured] = useState<boolean | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace('/login');
    }
  }, [user, isLoading, router]);

  const startCheckout = async () => {
    if (!token) return;
    setStarting(true);
    setError(null);
    try {
      const res = await api.post<{ data: { configured: boolean; checkout_url?: string } }>(
        '/billing/checkout-session',
        {},
        token,
      );
      if (!res.data.configured || !res.data.checkout_url) {
        setConfigured(false);
        return;
      }
      window.location.href = res.data.checkout_url;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not start checkout. Please try again.');
    } finally {
      setStarting(false);
    }
  };

  if (isLoading || !user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FFF8F5]">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF8F5] py-16 px-6">
      <div className="mx-auto max-w-2xl">
        <div className="text-center mb-10">
          <Heart className="mx-auto mb-3 text-[#D8909A]" size={32} />
          <h1 className="text-3xl font-medium text-[#2F4A3C]">One payment. Full access.</h1>
          <p className="mt-2 text-[#5A524D]">No subscriptions, no hidden fees.</p>
        </div>

        <div className="rounded-3xl bg-white shadow-xl overflow-hidden">
          <div className="p-8 text-center" style={{ backgroundColor: '#EBD9CE' }}>
            <p className="text-sm uppercase tracking-wide text-[#5A524D] font-medium">Complete Package</p>
            <div className="mt-2 text-5xl font-medium text-[#2D2D2F]">$45</div>
            <p className="mt-1 text-sm text-[#5A524D]">One-time payment · lifetime access</p>
          </div>
          <div className="p-8">
            <div className="space-y-3 mb-6">
              {features.map((feature) => (
                <div key={feature} className="flex items-center gap-3">
                  <div className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-[#D8909A30]">
                    <Check className="h-3 w-3 text-[#D8909A]" />
                  </div>
                  <span className="text-sm text-[#5A524D]">{feature}</span>
                </div>
              ))}
            </div>

            {configured === false ? (
              <p className="text-sm text-center text-gray-500 bg-gray-100 rounded-xl p-4">
                Payments aren&apos;t set up yet. Please check back shortly.
              </p>
            ) : (
              <>
                <button
                  onClick={startCheckout}
                  disabled={starting}
                  className="w-full py-4 rounded-full text-base font-semibold text-white shadow-md disabled:opacity-60"
                  style={{ backgroundColor: '#D8909A' }}
                >
                  {starting ? 'Redirecting to secure checkout...' : 'Proceed to payment'}
                </button>
                {error && <p className="mt-3 text-sm text-center text-red-500">{error}</p>}
                <p className="mt-3 text-xs text-center text-gray-400">
                  You&apos;ll be redirected to Stripe&apos;s secure checkout to complete your purchase.
                </p>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
