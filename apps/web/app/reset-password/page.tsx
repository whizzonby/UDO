import { Heart } from 'lucide-react';
import ResetForm from './reset-form';

export default async function ResetPasswordPage({
  searchParams,
}: {
  searchParams: Promise<{ token?: string; email?: string }>;
}) {
  const { token, email } = await searchParams;

  return (
    <div className="min-h-screen bg-[--color-udo-cream] flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="flex justify-center mb-8">
          <div className="w-12 h-12 rounded-2xl flex items-center justify-center"
            style={{ background: 'linear-gradient(135deg, #FF4D8C 0%, #D4006A 100%)' }}>
            <Heart size={22} className="text-white fill-white" />
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-[--color-udo-grey-200] shadow-sm p-8">
          {!token || !email ? (
            <div className="text-center py-4">
              <h2 className="font-display text-xl font-bold text-[--color-udo-grey-700] mb-3">
                Invalid reset link
              </h2>
              <p className="text-[--color-udo-grey-500] text-sm leading-relaxed">
                This password reset link is missing required information.
                Please request a new one from the Udo app.
              </p>
            </div>
          ) : (
            <>
              <div className="mb-6">
                <h1 className="font-display text-2xl font-bold text-[--color-udo-grey-700]">
                  Set new password
                </h1>
                <p className="text-[--color-udo-grey-500] text-sm mt-1">
                  Resetting password for{' '}
                  <span className="font-medium text-[--color-udo-grey-700]">{email}</span>
                </p>
              </div>
              <ResetForm token={token} email={email} />
            </>
          )}
        </div>

        <p className="text-center text-xs text-[--color-udo-grey-400] mt-6">
          Udo — Your wedding, beautifully planned.
        </p>
      </div>
    </div>
  );
}
