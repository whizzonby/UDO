'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, Heart } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';

type Plan = 'premium' | 'pass';

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

const PLANS: Record<Plan, { label: string; cents: number; cadence: string; blurb: string }> = {
  premium: { label: 'Udo Premium', cents: 499, cadence: '/month', blurb: 'Full wedding-planning access. Cancel anytime.' },
  pass: { label: 'Wedding Pass', cents: 4999, cadence: 'one time', blurb: 'One payment. Plan all the way to “I do.”' },
};

interface CouponPreview {
  code: string;
  discount_cents: number;
  total_cents: number;
  applies_to: string;
}

const dollars = (cents: number) => `$${(cents / 100).toFixed(2)}`;

export default function CheckoutPage() {
  const { user, token, isLoading } = useAuth();
  const router = useRouter();
  const [plan, setPlan] = useState<Plan>('pass');
  const [couponInput, setCouponInput] = useState('');
  const [coupon, setCoupon] = useState<CouponPreview | null>(null);
  const [couponError, setCouponError] = useState<string | null>(null);
  const [applying, setApplying] = useState(false);
  const [starting, setStarting] = useState(false);
  const [configured, setConfigured] = useState<boolean | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace('/login');
    }
  }, [user, isLoading, router]);

  useEffect(() => {
    const requested = new URLSearchParams(window.location.search).get('plan');
    if (requested === 'premium' || requested === 'pass') setPlan(requested);
  }, []);

  const choosePlan = (next: Plan) => {
    setPlan(next);
    // A coupon preview is priced for one plan; re-apply against the new one.
    setCoupon(null);
    setCouponError(null);
  };

  const applyCoupon = async () => {
    if (!token || !couponInput.trim()) return;
    setApplying(true);
    setCouponError(null);
    try {
      const res = await api.post<{ data: CouponPreview }>(
        '/billing/coupon-preview',
        { plan, coupon_code: couponInput.trim() },
        token,
      );
      setCoupon(res.data);
    } catch (e) {
      setCoupon(null);
      setCouponError(e instanceof Error ? e.message : 'Could not apply this code.');
    } finally {
      setApplying(false);
    }
  };

  const startCheckout = async () => {
    if (!token) return;
    setStarting(true);
    setError(null);
    try {
      const res = await api.post<{ data: { configured: boolean; checkout_url?: string } }>(
        '/billing/checkout-session',
        { plan, ...(coupon ? { coupon_code: coupon.code } : {}) },
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

  const selected = PLANS[plan];
  const total = coupon ? coupon.total_cents : selected.cents;

  return (
    <div className="min-h-screen bg-[#FFF8F5] py-16 px-6">
      <div className="mx-auto max-w-2xl">
        <div className="text-center mb-10">
          <Heart className="mx-auto mb-3 text-[#D8909A]" size={32} />
          <h1 className="text-3xl font-medium text-[#2F4A3C]">Choose how you pay</h1>
          <p className="mt-2 text-[#5A524D]">Monthly, or one payment for the whole wedding.</p>
        </div>

        <div className="grid grid-cols-2 gap-3 mb-6">
          {(Object.keys(PLANS) as Plan[]).map((key) => (
            <button
              key={key}
              type="button"
              onClick={() => choosePlan(key)}
              className={`rounded-2xl bg-white p-4 text-left transition-shadow ${
                plan === key ? 'ring-2 ring-[#2F4A3C] shadow-md' : 'ring-1 ring-gray-200'
              }`}
            >
              <p className="text-sm font-semibold text-[#2F4A3C]">{PLANS[key].label}</p>
              <p className="mt-1 text-2xl font-medium text-[#2D2D2F]">
                {dollars(PLANS[key].cents)}
                <span className="ml-1 text-xs font-normal text-[#5A524D]">{PLANS[key].cadence}</span>
              </p>
            </button>
          ))}
        </div>

        <div className="rounded-3xl bg-white shadow-xl overflow-hidden">
          <div className="p-8 text-center" style={{ backgroundColor: '#EBD9CE' }}>
            <p className="text-sm uppercase tracking-wide text-[#5A524D] font-medium">{selected.label}</p>
            <div className="mt-2 text-5xl font-medium text-[#2D2D2F]">
              {coupon && <span className="mr-3 text-2xl text-[#5A524D] line-through">{dollars(selected.cents)}</span>}
              {dollars(total)}
            </div>
            <p className="mt-1 text-sm text-[#5A524D]">
              {selected.blurb}
              {coupon && plan === 'premium' && ' Discount applies to your first month.'}
            </p>
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

            <div className="mb-6">
              <div className="flex gap-2">
                <input
                  value={couponInput}
                  onChange={(e) => {
                    setCouponInput(e.target.value.toUpperCase());
                    setCoupon(null);
                  }}
                  placeholder="Coupon code"
                  maxLength={40}
                  className="min-w-0 flex-1 rounded-full border border-gray-200 px-4 py-2.5 text-sm uppercase tracking-wide outline-none focus:border-[#D8909A]"
                />
                <button
                  type="button"
                  onClick={applyCoupon}
                  disabled={applying || !couponInput.trim()}
                  className="rounded-full border border-[#D8909A] px-5 py-2.5 text-sm font-semibold text-[#D8909A] disabled:opacity-50"
                >
                  {applying ? 'Applying...' : 'Apply'}
                </button>
              </div>
              {coupon && (
                <p className="mt-2 text-sm text-[#285301]">
                  {coupon.code} applied — you save {dollars(coupon.discount_cents)}.
                </p>
              )}
              {couponError && <p className="mt-2 text-sm text-red-500">{couponError}</p>}
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
                  {plan === 'premium' && ' Cancel anytime.'}
                </p>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
