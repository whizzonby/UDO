'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { CheckCircle2 } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';

type Entitlements = {
  plan: string;
  label: string;
  status: string;
  billing_cycle: string;
  description: string;
  features: string[];
  prices: { monthly: number; annual: number };
};

export default function DashboardBillingPage() {
  const { token } = useAuth();
  const [entitlements, setEntitlements] = useState<Entitlements | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!token) return;
    api
      .get<{ data: Entitlements }>('/billing/entitlements', token)
      .then((res) => setEntitlements(res.data))
      .finally(() => setLoading(false));
  }, [token]);

  if (loading) {
    return <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />;
  }

  const isLifetime = entitlements?.plan === 'lifetime';

  return (
    <div className="max-w-lg space-y-6">
      <h1 className="text-xl font-semibold text-gray-800">Billing</h1>

      <div className="rounded-2xl border border-gray-200 bg-white p-6">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm text-gray-400">Current plan</span>
          {isLifetime && (
            <span className="flex items-center gap-1 text-xs font-medium text-[#285301]">
              <CheckCircle2 size={14} /> Active
            </span>
          )}
        </div>
        <p className="text-2xl font-semibold text-gray-800">{entitlements?.label ?? 'Free'}</p>
        <p className="text-sm text-gray-500 mt-1">{entitlements?.description}</p>

        {!isLifetime && (
          <Link
            href="/checkout"
            className="mt-4 inline-block px-5 py-2.5 rounded-xl text-sm font-semibold text-white"
            style={{ backgroundColor: '#D8909A' }}
          >
            Get lifetime access — $45
          </Link>
        )}
      </div>

      {entitlements?.features && (
        <div className="rounded-2xl border border-gray-200 bg-white p-6">
          <h2 className="text-sm font-semibold text-gray-800 mb-3">What&apos;s included</h2>
          <ul className="space-y-2">
            {entitlements.features.map((feature) => (
              <li key={feature} className="flex items-center gap-2 text-sm text-gray-600">
                <CheckCircle2 size={14} className="text-[#285301]" />
                {feature}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
