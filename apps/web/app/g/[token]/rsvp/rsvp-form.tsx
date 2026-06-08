'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check } from 'lucide-react';
import { guestApi, type GuestData, type RsvpStatus } from '@/lib/api';
import { cn } from '@/lib/utils';

const STATUS_OPTIONS: { value: RsvpStatus; label: string; emoji: string; desc: string }[] = [
  { value: 'attending', label: "I'll be there!", emoji: '🎉', desc: 'Count me in' },
  { value: 'declined',  label: "Can't make it", emoji: '😢', desc: 'Sorry to miss it' },
  { value: 'maybe',    label: 'Not sure yet',  emoji: '🤔', desc: "I'll let you know" },
];

export function RsvpForm({ token, guest }: { token: string; guest: GuestData }) {
  const router = useRouter();
  const [status, setStatus] = useState<RsvpStatus | null>(
    guest.rsvp_status !== 'pending' ? guest.rsvp_status : null
  );
  const [dietary, setDietary] = useState(guest.dietary_requirements ?? '');
  const [plusOneAttending, setPlusOneAttending] = useState(false);
  const [plusOneName, setPlusOneName] = useState(guest.plus_one_name ?? '');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!status) return;

    setLoading(true);
    setError(null);

    try {
      const result = await guestApi.rsvp(token, {
        status,
        dietary_requirements: dietary || undefined,
        plus_one_attending: plusOneAttending,
        plus_one_name: plusOneName || undefined,
        message_to_couple: message || undefined,
      });
      setSuccess(result.message);
      setTimeout(() => router.push(`/g/${token}`), 2500);
    } catch {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  if (success) {
    return (
      <div className="text-center py-16">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-[--color-udo-teal]/15 mb-4">
          <Check size={28} className="text-[--color-udo-teal]" strokeWidth={2.5} />
        </div>
        <h2 className="font-display text-2xl font-bold text-[--color-udo-grey-700] mb-2">
          {status === 'attending' ? "You're in! 🎉" : 'Response saved'}
        </h2>
        <p className="text-[--color-udo-grey-500] text-sm">{success}</p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6 max-w-md mx-auto">
      {/* Status selection */}
      <div>
        <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-3">
          Will you attend?
        </p>
        <div className="space-y-2">
          {STATUS_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              type="button"
              onClick={() => setStatus(opt.value)}
              className={cn(
                'w-full flex items-center gap-4 rounded-2xl p-4 border-2 text-left transition-all',
                status === opt.value
                  ? 'border-[--color-udo-pink] bg-[--color-udo-blush]'
                  : 'border-[--color-udo-grey-200] bg-white hover:border-[--color-udo-grey-400]'
              )}
            >
              <span className="text-2xl leading-none">{opt.emoji}</span>
              <div className="flex-1">
                <p className={cn(
                  'font-semibold text-sm',
                  status === opt.value ? 'text-[--color-udo-pink]' : 'text-[--color-udo-grey-700]'
                )}>
                  {opt.label}
                </p>
                <p className="text-xs text-[--color-udo-grey-400]">{opt.desc}</p>
              </div>
              <div className={cn(
                'w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0',
                status === opt.value
                  ? 'border-[--color-udo-pink] bg-[--color-udo-pink]'
                  : 'border-[--color-udo-grey-300]'
              )}>
                {status === opt.value && <Check size={11} className="text-white" strokeWidth={3} />}
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Dietary */}
      {status === 'attending' && (
        <>
          <div>
            <label className="block text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-2">
              Dietary requirements
            </label>
            <textarea
              value={dietary}
              onChange={(e) => setDietary(e.target.value)}
              placeholder="Any allergies or dietary needs? (optional)"
              rows={2}
              className="w-full rounded-xl border border-[--color-udo-grey-200] bg-white px-4 py-3 text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:border-[--color-udo-pink] resize-none transition-colors"
            />
          </div>

          {guest.plus_one_allowed && (
            <div>
              <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-3">
                Your plus one
              </p>
              <div className="bg-white rounded-2xl border border-[--color-udo-grey-200] p-4 space-y-3">
                <label className="flex items-center gap-3 cursor-pointer">
                  <div
                    onClick={() => setPlusOneAttending(!plusOneAttending)}
                    className={cn(
                      'w-5 h-5 rounded border-2 flex items-center justify-center cursor-pointer transition-all',
                      plusOneAttending
                        ? 'border-[--color-udo-pink] bg-[--color-udo-pink]'
                        : 'border-[--color-udo-grey-300]'
                    )}
                  >
                    {plusOneAttending && <Check size={11} className="text-white" strokeWidth={3} />}
                  </div>
                  <span className="text-sm text-[--color-udo-grey-700] font-medium">
                    {guest.plus_one_name
                      ? `${guest.plus_one_name} will be joining me`
                      : 'My plus one will be joining me'}
                  </span>
                </label>
                {plusOneAttending && (
                  <input
                    type="text"
                    value={plusOneName}
                    onChange={(e) => setPlusOneName(e.target.value)}
                    placeholder="Their name (optional)"
                    className="w-full rounded-xl border border-[--color-udo-grey-200] bg-[--color-udo-grey-50] px-3 py-2.5 text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:border-[--color-udo-pink] transition-colors"
                  />
                )}
              </div>
            </div>
          )}
        </>
      )}

      {/* Message to couple */}
      {status && (
        <div>
          <label className="block text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-2">
            Message to the couple
          </label>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Say something lovely… (optional)"
            rows={3}
            className="w-full rounded-xl border border-[--color-udo-grey-200] bg-white px-4 py-3 text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:border-[--color-udo-pink] resize-none transition-colors"
          />
        </div>
      )}

      {error && (
        <p className="text-sm text-red-500 text-center">{error}</p>
      )}

      <button
        type="submit"
        disabled={!status || loading}
        className={cn(
          'w-full rounded-2xl py-4 font-semibold text-sm transition-all',
          status && !loading
            ? 'bg-[--color-udo-pink] text-white hover:bg-[--color-udo-pink-dark] active:scale-[0.98]'
            : 'bg-[--color-udo-grey-200] text-[--color-udo-grey-400] cursor-not-allowed'
        )}
      >
        {loading ? 'Sending…' : 'Submit RSVP'}
      </button>
    </form>
  );
}
