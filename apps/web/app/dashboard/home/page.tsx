'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Users, CheckCircle2, Calendar, Wallet, Pencil } from 'lucide-react';
import { useWedding } from '@/contexts/WeddingContext';
import { useAuth } from '@/contexts/AuthContext';
import { api } from '@/lib/api';
import { DownloadAppCard } from '@/components/dashboard/DownloadAppCard';

export default function DashboardHomePage() {
  const { wedding, stats, loading, refresh } = useWedding();
  const { token } = useAuth();
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({ couple_name_primary: '', couple_name_secondary: '', event_date: '', primary_venue_name: '' });

  const startEdit = () => {
    setForm({
      couple_name_primary: wedding?.couple_names?.split(' & ')[0] ?? '',
      couple_name_secondary: wedding?.couple_names?.split(' & ')[1] ?? '',
      event_date: wedding?.event_date ?? '',
      primary_venue_name: wedding?.venue_name ?? '',
    });
    setEditing(true);
  };

  const save = async () => {
    if (!token) return;
    setSaving(true);
    try {
      await api.patch('/wedding', form, token);
      await refresh();
      setEditing(false);
    } catch {
      // WeddingContext already handles the fetch-failure case silently elsewhere
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />;
  }

  if (!wedding) {
    return (
      <div className="text-center py-16">
        <p className="text-gray-500">No wedding found on your account yet.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <StatCard icon={Users} label="Guests" value={stats?.total_guests ?? 0} />
        <StatCard icon={CheckCircle2} label="Confirmed" value={stats?.confirmed_guests ?? 0} />
        <StatCard icon={Calendar} label="Days to go" value={wedding.days_until ?? '—'} />
        <StatCard icon={Wallet} label="Tasks left" value={stats?.pending_tasks ?? 0} />
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-base font-semibold text-gray-800">Your wedding</h2>
          {!editing && (
            <button onClick={startEdit} className="flex items-center gap-1 text-sm text-[#285301]">
              <Pencil size={14} /> Edit
            </button>
          )}
        </div>
        {editing ? (
          <div className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <input
                value={form.couple_name_primary}
                onChange={(e) => setForm({ ...form, couple_name_primary: e.target.value })}
                placeholder="Your name"
                className="border border-gray-200 rounded-xl px-3 py-2 text-sm"
              />
              <input
                value={form.couple_name_secondary}
                onChange={(e) => setForm({ ...form, couple_name_secondary: e.target.value })}
                placeholder="Partner's name"
                className="border border-gray-200 rounded-xl px-3 py-2 text-sm"
              />
            </div>
            <input
              type="date"
              value={form.event_date ?? ''}
              onChange={(e) => setForm({ ...form, event_date: e.target.value })}
              className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
            />
            <input
              value={form.primary_venue_name ?? ''}
              onChange={(e) => setForm({ ...form, primary_venue_name: e.target.value })}
              placeholder="Venue"
              className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
            />
            <div className="flex gap-2">
              <button onClick={save} disabled={saving} className="px-4 py-2 rounded-xl text-sm font-medium text-white bg-[#285301] disabled:opacity-60">
                {saving ? 'Saving...' : 'Save'}
              </button>
              <button onClick={() => setEditing(false)} className="px-4 py-2 rounded-xl text-sm font-medium text-gray-500">
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <div className="space-y-1 text-sm text-gray-600">
            <p className="text-lg font-medium text-gray-800">{wedding.couple_names}</p>
            {wedding.event_date && <p>{new Date(wedding.event_date).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>}
            {(wedding.venue_name || wedding.venue_city) && <p>{[wedding.venue_name, wedding.venue_city].filter(Boolean).join(' · ')}</p>}
          </div>
        )}
      </div>

      <DownloadAppCard />

      <p className="text-center text-sm text-gray-400">
        Need to manage guests, seating, budget, or your gallery?{' '}
        <Link href="/checkout" className="text-[#285301] font-medium">Do it all in the Udo app</Link>.
      </p>
    </div>
  );
}

function StatCard({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: number | string }) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-4">
      <Icon className="text-[#285301] mb-2" size={18} />
      <p className="text-2xl font-semibold text-gray-800">{value}</p>
      <p className="text-xs text-gray-400">{label}</p>
    </div>
  );
}
