'use client';

import { useState } from 'react';
import { CheckCircle, Eye, EyeOff, Lock } from 'lucide-react';

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

interface Props {
  token: string;
  email: string;
}

export default function ResetForm({ token, email }: Props) {
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (password.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }
    if (password !== confirm) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/auth/reset-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({
          token,
          email,
          password,
          password_confirmation: confirm,
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setError(data.message ?? 'Something went wrong. Please try again.');
      } else {
        setSuccess(true);
      }
    } catch {
      setError('Could not connect to the server. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  if (success) {
    return (
      <div className="flex flex-col items-center text-center gap-4 py-8">
        <div className="w-16 h-16 rounded-full bg-[--color-udo-teal]/10 flex items-center justify-center">
          <CheckCircle size={32} className="text-[--color-udo-teal]" />
        </div>
        <h2 className="font-display text-2xl font-bold text-[--color-udo-grey-700]">
          Password reset!
        </h2>
        <p className="text-[--color-udo-grey-500] text-sm leading-relaxed max-w-xs">
          Your password has been updated. Open the Udo app and sign in with your new password.
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4">
      {/* New password */}
      <div className="flex flex-col gap-1.5">
        <label className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">
          New password
        </label>
        <div className="relative">
          <Lock
            size={16}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[--color-udo-grey-400]"
          />
          <input
            type={showPw ? 'text' : 'password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="At least 8 characters"
            required
            minLength={8}
            className="w-full pl-9 pr-10 py-3 rounded-xl border border-[--color-udo-grey-200] bg-[--color-udo-grey-100] text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:ring-2 focus:ring-[--color-udo-pink]/40 focus:border-[--color-udo-pink]"
          />
          <button
            type="button"
            onClick={() => setShowPw((v) => !v)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-[--color-udo-grey-400]"
            tabIndex={-1}
          >
            {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
          </button>
        </div>
      </div>

      {/* Confirm password */}
      <div className="flex flex-col gap-1.5">
        <label className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">
          Confirm new password
        </label>
        <div className="relative">
          <Lock
            size={16}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-[--color-udo-grey-400]"
          />
          <input
            type={showPw ? 'text' : 'password'}
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
            placeholder="Repeat your new password"
            required
            className="w-full pl-9 pr-4 py-3 rounded-xl border border-[--color-udo-grey-200] bg-[--color-udo-grey-100] text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:ring-2 focus:ring-[--color-udo-pink]/40 focus:border-[--color-udo-pink]"
          />
        </div>
      </div>

      {/* Error */}
      {error && (
        <p className="text-sm text-red-500 bg-red-50 rounded-xl px-4 py-3">
          {error}
        </p>
      )}

      {/* Submit */}
      <button
        type="submit"
        disabled={loading}
        className="w-full py-3.5 rounded-xl font-semibold text-white text-sm transition-opacity disabled:opacity-60"
        style={{ background: 'linear-gradient(135deg, #FF4D8C 0%, #D4006A 100%)' }}
      >
        {loading ? 'Resetting…' : 'Reset password'}
      </button>
    </form>
  );
}
