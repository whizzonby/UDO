'use client';

import { Suspense, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { setAuth, type AuthUser } from '@/lib/auth';
import { api } from '@/lib/api';

function CallbackInner() {
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    const token = searchParams.get('token');
    const onboardingDone = searchParams.get('onboarding');

    if (!token) {
      router.replace('/login?error=oauth_failed');
      return;
    }

    (api.get('/auth/me', token) as Promise<AuthUser>)
      .then(user => {
        setAuth(token, user);
        if (onboardingDone === 'false' || onboardingDone === '0') {
          router.replace('/onboarding');
        } else {
          router.replace('/dashboard/home');
        }
      })
      .catch(() => {
        router.replace('/login?error=oauth_failed');
      });
  }, []);

  return (
    <div className="h-screen flex items-center justify-center bg-white">
      <div className="text-center">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin mx-auto mb-4" />
        <p className="text-gray-500 text-sm">Signing you in...</p>
      </div>
    </div>
  );
}

export default function AuthCallbackPage() {
  return (
    <Suspense fallback={
      <div className="h-screen flex items-center justify-center bg-white">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    }>
      <CallbackInner />
    </Suspense>
  );
}
