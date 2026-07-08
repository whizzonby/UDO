'use client';

import { useEffect, useState } from 'react';
import { Heart, MapPin, Calendar, Clock, Check, X } from 'lucide-react';

type GuestData = {
  first_name: string;
  last_name: string;
  attending_status: 'pending' | 'yes' | 'no';
  plus_one_allowed: boolean;
  plus_one_count: number;
  meal_preference: string | null;
  travel_required: boolean;
  arrival_date: string | null;
  departure_date: string | null;
};

type WeddingData = {
  title: string | null;
  couple_name_primary: string;
  couple_name_secondary: string | null;
  event_date: string | null;
  city: string | null;
  country: string | null;
  venue: string | null;
  venue_address: string | null;
  rsvp_deadline: string | null;
};

type PortalData = {
  view_type: string;
  guest: GuestData;
  wedding: WeddingData;
};

export default function GuestPortal({ token }: { token: string }) {
  const [data, setData] = useState<PortalData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [rsvpStatus, setRsvpStatus] = useState<'pending' | 'yes' | 'no' | null>(null);
  const [plusOneCount, setPlusOneCount] = useState(0);
  const [mealPref, setMealPref] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const API = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

  useEffect(() => {
    fetch(`${API}/g/${token}`)
      .then(r => {
        if (!r.ok) throw new Error('Invalid or expired invitation link.');
        return r.json();
      })
      .then(d => {
        setData(d);
        setRsvpStatus(d.guest.attending_status === 'pending' ? null : d.guest.attending_status);
        setPlusOneCount(d.guest.plus_one_count ?? 0);
        setMealPref(d.guest.meal_preference ?? '');
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, [token]);

  const submitRsvp = async (status: 'yes' | 'no') => {
    setSubmitting(true);
    setRsvpStatus(status);
    try {
      const res = await fetch(`${API}/g/${token}/rsvp`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ attending_status: status, plus_one_count: plusOneCount, meal_preference: mealPref }),
      });
      if (!res.ok) throw new Error('Failed to save RSVP.');
      setSubmitted(true);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to save RSVP.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb]">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb] p-6">
        <div className="text-center">
          <Heart className="mx-auto mb-4 text-[#d45d78]" size={48} />
          <h1 className="text-xl font-semibold text-gray-800 mb-2">Link Not Found</h1>
          <p className="text-gray-500">{error ?? 'This invitation link is invalid or has expired.'}</p>
        </div>
      </div>
    );
  }

  const { guest, wedding } = data;
  const coupleName = wedding.couple_name_secondary
    ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
    : wedding.couple_name_primary;

  const eventDate = wedding.event_date
    ? new Date(wedding.event_date).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
    : null;

  if (submitted) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-[#f8edeb] p-6 text-center">
        <div className="w-16 h-16 rounded-full bg-[#285301] flex items-center justify-center mx-auto mb-6">
          {rsvpStatus === 'yes' ? <Check className="text-white" size={32} /> : <X className="text-white" size={32} />}
        </div>
        <h1 className="text-2xl font-bold text-gray-800 mb-2">
          {rsvpStatus === 'yes' ? "We'll see you there!" : "We'll miss you."}
        </h1>
        <p className="text-gray-500 mb-4">
          {rsvpStatus === 'yes'
            ? `Your RSVP for ${coupleName}'s wedding has been confirmed.`
            : `Thank you for letting ${coupleName} know.`}
        </p>
        <Heart className="text-[#d45d78]" size={24} fill="#d45d78" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#f8edeb]">
      {/* Header */}
      <div className="bg-white px-6 pt-12 pb-8 text-center border-b border-gray-100">
        <div className="w-12 h-12 rounded-full bg-[#f194b2] flex items-center justify-center mx-auto mb-4">
          <Heart className="text-white" size={22} fill="white" />
        </div>
        <p className="text-sm text-[#d45d78] font-medium mb-1">You are invited to</p>
        <h1 className="text-2xl font-bold text-[#285301]">{wedding.title ?? `${coupleName}'s Wedding`}</h1>
        <p className="text-gray-500 mt-1 text-sm">{coupleName}</p>
      </div>

      {/* Wedding Details */}
      <div className="bg-white mx-4 mt-4 rounded-2xl p-5 space-y-3 shadow-sm">
        {eventDate && (
          <div className="flex items-center gap-3 text-sm">
            <Calendar size={16} className="text-[#285301] flex-shrink-0" />
            <span className="text-gray-700">{eventDate}</span>
          </div>
        )}
        {(wedding.venue || wedding.city) && (
          <div className="flex items-center gap-3 text-sm">
            <MapPin size={16} className="text-[#285301] flex-shrink-0" />
            <div>
              {wedding.venue && <p className="text-gray-700 font-medium">{wedding.venue}</p>}
              {(wedding.city || wedding.country) && (
                <p className="text-gray-500">{[wedding.city, wedding.country].filter(Boolean).join(', ')}</p>
              )}
            </div>
          </div>
        )}
        {wedding.rsvp_deadline && (
          <div className="flex items-center gap-3 text-sm">
            <Clock size={16} className="text-[#285301] flex-shrink-0" />
            <span className="text-gray-500">RSVP by {new Date(wedding.rsvp_deadline).toLocaleDateString()}</span>
          </div>
        )}
      </div>

      {/* Guest greeting */}
      <div className="mx-4 mt-4 mb-2">
        <h2 className="text-lg font-semibold text-gray-800">
          Hi, {guest.first_name}!
        </h2>
        <p className="text-sm text-gray-500 mt-1">Will you be joining us on this special day?</p>
      </div>

      {/* Meal preference (if attending) */}
      {rsvpStatus === 'yes' && (
        <div className="bg-white mx-4 mt-2 rounded-2xl p-5 shadow-sm space-y-3">
          {guest.plus_one_allowed && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Plus ones</label>
              <select
                className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
                value={plusOneCount}
                onChange={e => setPlusOneCount(Number(e.target.value))}
              >
                {[0, 1, 2, 3, 4, 5].map(n => (
                  <option key={n} value={n}>{n === 0 ? 'Just me' : `+${n}`}</option>
                ))}
              </select>
            </div>
          )}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Meal preference</label>
            <select
              className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
              value={mealPref}
              onChange={e => setMealPref(e.target.value)}
            >
              <option value="">No preference</option>
              <option value="standard">Standard</option>
              <option value="vegetarian">Vegetarian</option>
              <option value="vegan">Vegan</option>
              <option value="halal">Halal</option>
              <option value="kosher">Kosher</option>
              <option value="gluten-free">Gluten-Free</option>
            </select>
          </div>
        </div>
      )}

      {/* RSVP Buttons */}
      <div className="mx-4 mt-4 space-y-3 pb-10">
        <button
          disabled={submitting}
          onClick={() => submitRsvp('yes')}
          className={`w-full py-4 rounded-2xl font-semibold text-base transition-all ${
            rsvpStatus === 'yes'
              ? 'bg-[#285301] text-white'
              : 'bg-[#285301]/10 text-[#285301] border border-[#285301]/20'
          }`}
        >
          {rsvpStatus === 'yes' ? '✓ Attending' : 'Yes, I will be there!'}
        </button>
        <button
          disabled={submitting}
          onClick={() => rsvpStatus === 'yes' ? submitRsvp('yes') : submitRsvp('no')}
          className={`w-full py-4 rounded-2xl font-semibold text-base transition-all ${
            rsvpStatus === 'no'
              ? 'bg-red-500 text-white'
              : 'bg-gray-100 text-gray-500'
          }`}
        >
          {rsvpStatus === 'no' ? '✗ Declined' : "Sorry, I can't make it"}
        </button>
        {rsvpStatus === 'yes' && (
          <button
            disabled={submitting}
            onClick={() => submitRsvp('yes')}
            className="w-full py-4 rounded-2xl font-semibold text-base bg-[#285301] text-white"
          >
            {submitting ? 'Saving...' : 'Confirm RSVP'}
          </button>
        )}
      </div>
    </div>
  );
}
