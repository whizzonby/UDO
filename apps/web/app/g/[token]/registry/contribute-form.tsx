'use client';

import { useState } from 'react';
import { Heart, Loader2 } from 'lucide-react';
import { guestApi, type CashFund } from '@/lib/api';

const PRESETS = [25, 50, 100, 250];

export function ContributeForm({ token, fund }: { token: string; fund: CashFund }) {
  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState<number | 'custom'>(50);
  const [custom, setCustom] = useState('');
  const [name, setName] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const amount = selected === 'custom' ? parseFloat(custom) || 0 : selected;

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (amount < 1) { setError('Minimum contribution is $1'); return; }
    setError('');
    setLoading(true);
    try {
      const { checkout_url } = await guestApi.contribute(token, {
        amount,
        name: name.trim() || undefined,
        message: message.trim() || undefined,
      });
      window.location.href = checkout_url;
    } catch {
      setError('Something went wrong. Please try again.');
      setLoading(false);
    }
  }

  if (!open) {
    return (
      <button
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-2 bg-white/20 hover:bg-white/30 active:bg-white/40 transition-colors rounded-xl px-4 py-2.5 text-sm font-semibold text-white"
      >
        <Heart size={15} className="fill-white/60 stroke-white" />
        Contribute
      </button>
    );
  }

  return (
    <div className="mt-4 bg-white/15 rounded-2xl p-4 backdrop-blur-sm">
      <form onSubmit={submit} className="space-y-4">
        {/* Amount presets */}
        <div>
          <p className="text-white/80 text-xs font-semibold mb-2 uppercase tracking-wider">Choose amount</p>
          <div className="grid grid-cols-4 gap-2">
            {PRESETS.map((p) => (
              <button
                key={p}
                type="button"
                onClick={() => { setSelected(p); setCustom(''); }}
                className={`rounded-xl py-2 text-sm font-semibold transition-colors ${
                  selected === p
                    ? 'bg-white text-[--color-udo-pink-dark]'
                    : 'bg-white/20 text-white hover:bg-white/30'
                }`}
              >
                ${p}
              </button>
            ))}
          </div>
          <button
            type="button"
            onClick={() => setSelected('custom')}
            className={`mt-2 w-full rounded-xl py-2 text-sm font-semibold transition-colors ${
              selected === 'custom'
                ? 'bg-white text-[--color-udo-pink-dark]'
                : 'bg-white/20 text-white hover:bg-white/30'
            }`}
          >
            Custom amount
          </button>
          {selected === 'custom' && (
            <div className="mt-2 relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-[--color-udo-grey-500] font-semibold text-sm">$</span>
              <input
                type="number"
                min="1"
                step="1"
                placeholder="0"
                value={custom}
                onChange={(e) => setCustom(e.target.value)}
                className="w-full bg-white rounded-xl pl-7 pr-4 py-2.5 text-sm text-[--color-udo-grey-700] font-semibold placeholder-[--color-udo-grey-300] focus:outline-none focus:ring-2 focus:ring-white/50"
              />
            </div>
          )}
        </div>

        {/* Optional fields */}
        <div className="space-y-2">
          <input
            type="text"
            placeholder="Your name (optional)"
            value={name}
            onChange={(e) => setName(e.target.value)}
            maxLength={200}
            className="w-full bg-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/50"
          />
          <textarea
            placeholder="Leave a message (optional)"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            maxLength={500}
            rows={2}
            className="w-full bg-white/20 rounded-xl px-4 py-2.5 text-sm text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-white/50 resize-none"
          />
        </div>

        {error && <p className="text-white/90 text-xs font-medium bg-black/20 rounded-lg px-3 py-2">{error}</p>}

        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setOpen(false)}
            className="flex-1 rounded-xl py-2.5 text-sm font-semibold text-white/70 hover:text-white transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={loading || amount < 1}
            className="flex-[2] bg-white text-[--color-udo-pink-dark] rounded-xl py-2.5 text-sm font-bold disabled:opacity-50 flex items-center justify-center gap-2 hover:bg-white/90 transition-colors"
          >
            {loading ? (
              <Loader2 size={16} className="animate-spin" />
            ) : (
              <>Contribute {amount >= 1 ? `$${amount}` : ''}</>
            )}
          </button>
        </div>
      </form>
    </div>
  );
}
