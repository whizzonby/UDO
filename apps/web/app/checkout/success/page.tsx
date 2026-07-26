'use client';

import { Suspense, useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { CheckCircle2 } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';
import { DownloadAppCard } from '@/components/dashboard/DownloadAppCard';

type SessionStatus = {
  payment_status: string;
  amount_total: number;
  currency: string;
};

function CheckoutSuccessContent() {
  const { token, isLoading: authLoading } = useAuth();
  const params = useSearchParams();
  const sessionId = params.get('session_id');
  const [status, setStatus] = useState<SessionStatus | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (authLoading) return;
    if (!token || !sessionId) {
      setLoading(false);
      setError('We could not confirm this payment.');
      return;
    }
    api
      .get<{ data: SessionStatus }>(`/billing/checkout-session/${sessionId}`, token)
      .then((res) => setStatus(res.data))
      .catch((e) => setError(e instanceof Error ? e.message : 'We could not confirm this payment.'))
      .finally(() => setLoading(false));
  }, [token, sessionId, authLoading]);

  if (authLoading || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FFF8F5]">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF8F5] py-16 px-6">
      <div className="mx-auto max-w-lg text-center">
        {error || status?.payment_status !== 'paid' ? (
          <>
            <h1 className="text-2xl font-medium text-[#2F4A3C] mb-2">We couldn&apos;t confirm this payment</h1>
            <p className="text-[#5A524D]">{error ?? 'Please contact support if you were charged.'}</p>
          </>
        ) : (
          <>
            <CheckCircle2 className="mx-auto mb-4 text-[#285301]" size={56} />
            <h1 className="text-3xl font-medium text-[#2F4A3C] mb-2">You&apos;re all set!</h1>
            <p className="text-[#5A524D] mb-1">
              ${(status.amount_total / 100).toFixed(2)} {status.currency.toUpperCase()} — lifetime access
            </p>
            <p className="text-sm text-gray-400 mb-10">A receipt has been sent to your email.</p>

            <div className="text-left">
              <DownloadAppCard />
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export default function CheckoutSuccessPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center bg-[#FFF8F5]">
          <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
        </div>
      }
    >
      <CheckoutSuccessContent />
    </Suspense>
  );
}
