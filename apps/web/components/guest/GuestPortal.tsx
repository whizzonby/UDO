'use client';

/* eslint-disable @next/next/no-img-element */

import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import { Calendar, Check, Clock, Gift, Heart, Image as ImageIcon, MapPin, Radio, X } from 'lucide-react';

type GuestData = {
  first_name: string;
  last_name: string;
  attending_status: 'pending' | 'yes' | 'no';
  plus_one_allowed: boolean;
  plus_one_count: number;
  meal_preference: string | null;
  travel_required: boolean;
  arrival_date: string | null;
  arrival_time: string | null;
  departure_date: string | null;
  departure_time: string | null;
  arrival_airport: string | null;
  communication_preferences: CommunicationPreferences;
};

type CommunicationPreferences = {
  email_opt_out: boolean;
  sms_opt_out: boolean;
  whatsapp_opt_out: boolean;
  updated_at: string | null;
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

type ExperienceData = {
  publish_state: 'draft' | 'published' | 'paused';
  published: boolean;
  welcome_message: string | null;
  dress_code: string | null;
  dress_code_details: string | null;
  cover_image_url: string | null;
  theme_color: string;
  layout_order: string[];
  access_rules: Record<string, unknown>;
  sections: {
    schedule: boolean;
    venue_map: boolean;
    accommodation: boolean;
    transport: boolean;
    seating: boolean;
    dress_code: boolean;
    registry: boolean;
    gallery: boolean;
    live_feed: boolean;
    photo_uploads: boolean;
    messages: boolean;
    rsvp: boolean;
    meal_selection: boolean;
    plus_one: boolean;
  };
};

type ScheduleItem = {
  id: number;
  title: string;
  description: string | null;
  event_date: string | null;
  start_time: string | null;
  end_time: string | null;
  location: string | null;
};

type RegistryItem = {
  id: number;
  type: string;
  name: string;
  description: string | null;
  image_url: string | null;
  store_name: string | null;
  store_url: string | null;
  price: string | null;
  currency: string | null;
  fund_goal: string | null;
  fund_raised: string | null;
  is_priority: boolean;
};

type GalleryItem = {
  id: number;
  type: string;
  url: string;
  thumbnail_url: string | null;
  caption: string | null;
  is_featured: boolean;
};

type LiveUpdate = {
  id: number;
  type: string;
  title: string;
  body: string | null;
  image_url: string | null;
  pinned: boolean;
  event_time: string | null;
};

type AccommodationItem = {
  id: number;
  name: string;
  type: string | null;
  address: string | null;
  city: string | null;
  country: string | null;
  price_per_night: string | null;
  currency: string | null;
  booking_code: string | null;
  website: string | null;
  distance_from_venue_km: string | null;
  check_in_date: string | null;
  check_out_date: string | null;
  notes: string | null;
  assigned_to_guest: boolean;
};

type TransportItem = {
  id: number;
  name: string;
  type: string | null;
  pickup_location: string | null;
  dropoff_location: string | null;
  departure_time: string | null;
  driver_name: string | null;
  driver_phone: string | null;
  notes: string | null;
};

type SeatingAssignment = {
  table_id: number;
  table_name: string;
  table_shape: string;
  event_section: string | null;
  seat_number: number;
  seat_label: string | null;
  notes: string | null;
};

type PortalData = {
  view_type: string;
  experience: ExperienceData;
  guest: GuestData;
  wedding: WeddingData;
  sections: {
    schedule: ScheduleItem[];
    accommodation: AccommodationItem[];
    transport: TransportItem[];
    seating: SeatingAssignment | null;
    registry: RegistryItem[];
    gallery: GalleryItem[];
    live_updates: LiveUpdate[];
  };
};

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

export default function GuestPortal({ token }: { token: string }) {
  const [data, setData] = useState<PortalData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [rsvpStatus, setRsvpStatus] = useState<'pending' | 'yes' | 'no' | null>(null);
  const [plusOneCount, setPlusOneCount] = useState(0);
  const [mealPref, setMealPref] = useState('');
  const [preferences, setPreferences] = useState<CommunicationPreferences | null>(null);
  const [preferencesSaving, setPreferencesSaving] = useState(false);
  const [preferencesSaved, setPreferencesSaved] = useState(false);
  const [preferencesError, setPreferencesError] = useState<string | null>(null);
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [photoCaption, setPhotoCaption] = useState('');
  const [photoSaving, setPhotoSaving] = useState(false);
  const [photoMessage, setPhotoMessage] = useState<string | null>(null);
  const [registrySavingId, setRegistrySavingId] = useState<number | null>(null);
  const [registryMessage, setRegistryMessage] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    fetch(`${API_BASE}/g/${token}`)
      .then(r => {
        if (!r.ok) throw new Error('Invalid or expired invitation link.');
        return r.json();
      })
      .then((d: PortalData) => {
        setData(d);
        setRsvpStatus(d.guest.attending_status === 'pending' ? null : d.guest.attending_status);
        setPlusOneCount(d.guest.plus_one_count ?? 0);
        setMealPref(d.guest.meal_preference ?? '');
        setPreferences(d.guest.communication_preferences);
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, [token]);

  const submitRsvp = async (status: 'yes' | 'no') => {
    if (!data?.experience.sections.rsvp) return;
    setSubmitting(true);
    setRsvpStatus(status);
    try {
      const res = await fetch(`${API_BASE}/g/${token}/rsvp`, {
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

  const savePreferences = async (nextPreferences: CommunicationPreferences) => {
    setPreferencesSaving(true);
    setPreferencesSaved(false);
    setPreferencesError(null);
    setPreferences(nextPreferences);
    try {
      const res = await fetch(`${API_BASE}/g/${token}/preferences`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(nextPreferences),
      });
      if (!res.ok) throw new Error('Failed to save preferences.');
      const saved = await res.json();
      setPreferences(saved.communication_preferences);
      setPreferencesSaved(true);
    } catch (e) {
      setPreferencesError(e instanceof Error ? e.message : 'Failed to save preferences.');
    } finally {
      setPreferencesSaving(false);
    }
  };

  const uploadPhoto = async () => {
    if (!photoFile) return;
    setPhotoSaving(true);
    setPhotoMessage(null);
    try {
      const form = new FormData();
      form.append('file', photoFile);
      if (photoCaption.trim()) form.append('caption', photoCaption.trim());
      const res = await fetch(`${API_BASE}/g/${token}/gallery`, { method: 'POST', body: form });
      if (!res.ok) throw new Error('Could not upload this photo.');
      setPhotoFile(null);
      setPhotoCaption('');
      setPhotoMessage('Photo uploaded for review.');
    } catch (e) {
      setPhotoMessage(e instanceof Error ? e.message : 'Could not upload this photo.');
    } finally {
      setPhotoSaving(false);
    }
  };

  const contributeRegistry = async (item: RegistryItem) => {
    if (!data) return;
    setRegistrySavingId(item.id);
    setRegistryMessage(null);
    const guestName = [data.guest.first_name, data.guest.last_name].filter(Boolean).join(' ') || 'Guest';
    try {
      const amount = item.type === 'cash_fund' ? 50 : Number(item.price ?? 0);
      const res = await fetch(`${API_BASE}/g/${token}/registry/${item.id}/contribute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({
          contributor_name: guestName,
          amount,
          quantity: 1,
        }),
      });
      if (!res.ok) throw new Error('Could not record contribution.');
      setRegistryMessage('Thank you. Your contribution has been recorded.');
    } catch (err) {
      setRegistryMessage(err instanceof Error ? err.message : 'Could not record contribution.');
    } finally {
      setRegistrySavingId(null);
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

  const { guest, wedding, experience, sections } = data;
  const portalColor = experience.theme_color || '#285301';
  const coupleName = wedding.couple_name_secondary
    ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
    : wedding.couple_name_primary;
  const eventDate = wedding.event_date
    ? new Date(wedding.event_date).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })
    : null;

  if (submitted) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-[#f8edeb] p-6 text-center">
        <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6" style={{ backgroundColor: portalColor }}>
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

  if (!experience.published) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb] p-6">
        <div className="text-center max-w-sm">
          <Heart className="mx-auto mb-4 text-[#d45d78]" size={48} />
          <h1 className="text-xl font-semibold text-gray-800 mb-2">Guest Portal Coming Soon</h1>
          <p className="text-gray-500">This wedding experience is being prepared. Please check your invitation again later.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#f8edeb] pb-8">
      <div
        className="bg-white px-6 pt-12 pb-8 text-center border-b border-gray-100"
        style={experience.cover_image_url ? { backgroundImage: `linear-gradient(rgba(255,255,255,.86), rgba(255,255,255,.94)), url(${experience.cover_image_url})`, backgroundSize: 'cover', backgroundPosition: 'center' } : undefined}
      >
        <div className="w-12 h-12 rounded-full bg-[#f194b2] flex items-center justify-center mx-auto mb-4">
          <Heart className="text-white" size={22} fill="white" />
        </div>
        <p className="text-sm text-[#d45d78] font-medium mb-1">You are invited to</p>
        <h1 className="text-2xl font-bold" style={{ color: portalColor }}>{wedding.title ?? `${coupleName}'s Wedding`}</h1>
        <p className="text-gray-500 mt-1 text-sm">{coupleName}</p>
      </div>

      {experience.welcome_message && (
        <section className="bg-white mx-4 mt-4 rounded-2xl p-5 shadow-sm">
          <p className="text-sm text-gray-700 leading-6">{experience.welcome_message}</p>
        </section>
      )}

      <section className="bg-white mx-4 mt-4 rounded-2xl p-5 space-y-3 shadow-sm">
        {eventDate && <InfoRow icon={<Calendar size={16} style={{ color: portalColor }} />} text={eventDate} />}
        {experience.sections.venue_map && (wedding.venue || wedding.city) && (
          <div className="flex items-center gap-3 text-sm">
            <MapPin size={16} className="flex-shrink-0" style={{ color: portalColor }} />
            <div>
              {wedding.venue && <p className="text-gray-700 font-medium">{wedding.venue}</p>}
              {(wedding.city || wedding.country) && <p className="text-gray-500">{[wedding.city, wedding.country].filter(Boolean).join(', ')}</p>}
              {wedding.venue_address && <p className="text-gray-400 text-xs mt-1">{wedding.venue_address}</p>}
            </div>
          </div>
        )}
        {wedding.rsvp_deadline && <InfoRow icon={<Clock size={16} style={{ color: portalColor }} />} text={`RSVP by ${new Date(wedding.rsvp_deadline).toLocaleDateString()}`} muted />}
        {guest.travel_required && (
          <InfoRow
            icon={<MapPin size={16} style={{ color: portalColor }} />}
            text={[
              guest.arrival_airport,
              guest.arrival_date ? `Arriving ${new Date(guest.arrival_date).toLocaleDateString()}` : null,
              guest.arrival_time,
            ].filter(Boolean).join(' - ') || 'Travel details pending'}
            muted
          />
        )}
      </section>

      {experience.sections.rsvp && (
        <>
          <section className="mx-4 mt-4 mb-2">
            <h2 className="text-lg font-semibold text-gray-800">Hi, {guest.first_name}!</h2>
            <p className="text-sm text-gray-500 mt-1">Will you be joining us on this special day?</p>
          </section>

          {rsvpStatus === 'yes' && (
            <section className="bg-white mx-4 mt-2 rounded-2xl p-5 shadow-sm space-y-3">
              {experience.sections.plus_one && guest.plus_one_allowed && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Plus ones</label>
                  <select className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" value={plusOneCount} onChange={e => setPlusOneCount(Number(e.target.value))}>
                    {[0, 1, 2, 3, 4, 5].map(n => <option key={n} value={n}>{n === 0 ? 'Just me' : `+${n}`}</option>)}
                  </select>
                </div>
              )}
              {experience.sections.meal_selection && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Meal preference</label>
                  <select className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" value={mealPref} onChange={e => setMealPref(e.target.value)}>
                    <option value="">No preference</option>
                    <option value="standard">Standard</option>
                    <option value="vegetarian">Vegetarian</option>
                    <option value="vegan">Vegan</option>
                    <option value="halal">Halal</option>
                    <option value="kosher">Kosher</option>
                    <option value="gluten-free">Gluten-Free</option>
                  </select>
                </div>
              )}
            </section>
          )}

          <section className="mx-4 mt-4 space-y-3">
            <button
              disabled={submitting}
              onClick={() => submitRsvp('yes')}
              className="w-full py-4 rounded-2xl font-semibold text-base transition-all"
              style={rsvpStatus === 'yes' ? { backgroundColor: portalColor, color: 'white' } : { color: portalColor, border: `1px solid ${portalColor}33`, backgroundColor: `${portalColor}1A` }}
            >
              {rsvpStatus === 'yes' ? 'Attending' : 'Yes, I will be there!'}
            </button>
            <button
              disabled={submitting}
              onClick={() => submitRsvp('no')}
              className={`w-full py-4 rounded-2xl font-semibold text-base transition-all ${rsvpStatus === 'no' ? 'bg-red-500 text-white' : 'bg-gray-100 text-gray-500'}`}
            >
              {rsvpStatus === 'no' ? 'Declined' : "Sorry, I can't make it"}
            </button>
            {rsvpStatus === 'yes' && (
              <button disabled={submitting} onClick={() => submitRsvp('yes')} className="w-full py-4 rounded-2xl font-semibold text-base text-white" style={{ backgroundColor: portalColor }}>
                {submitting ? 'Saving...' : 'Confirm RSVP'}
              </button>
            )}
          </section>
        </>
      )}

      {experience.sections.dress_code && (experience.dress_code || experience.dress_code_details) && (
        <Card title="Dress code">
          {experience.dress_code && <p className="text-sm font-medium" style={{ color: portalColor }}>{experience.dress_code}</p>}
          {experience.dress_code_details && <p className="mt-1 text-sm text-gray-500 leading-6">{experience.dress_code_details}</p>}
        </Card>
      )}

      {experience.sections.schedule && sections.schedule.length > 0 && (
        <Card title="Schedule">
          <div className="space-y-3">
            {sections.schedule.map(item => (
              <div key={item.id} className="border-l-2 pl-3" style={{ borderColor: portalColor }}>
                <p className="text-sm font-medium text-gray-800">{item.title}</p>
                <p className="text-xs text-gray-500">{[item.event_date ? new Date(item.event_date).toLocaleDateString() : null, item.start_time, item.location].filter(Boolean).join(' - ')}</p>
                {item.description && <p className="mt-1 text-xs text-gray-500 leading-5">{item.description}</p>}
              </div>
            ))}
          </div>
        </Card>
      )}

      {experience.sections.accommodation && sections.accommodation.length > 0 && (
        <Card title="Accommodation" icon={<MapPin size={16} style={{ color: portalColor }} />}>
          <div className="space-y-3">
            {sections.accommodation.map(item => (
              <a key={item.id} href={item.website ?? undefined} className={`block rounded-xl border p-3 ${item.assigned_to_guest ? 'border-[#285301] bg-[#285301]/5' : 'border-gray-100'}`}>
                <p className="text-sm font-medium text-gray-800">{item.name}</p>
                <p className="mt-1 text-xs text-gray-500">{[item.city, item.country, item.distance_from_venue_km ? `${item.distance_from_venue_km} km from venue` : null].filter(Boolean).join(' - ')}</p>
                {item.booking_code && <p className="mt-2 text-xs font-medium" style={{ color: portalColor }}>Booking code: {item.booking_code}</p>}
                {item.notes && <p className="mt-1 text-xs text-gray-500 leading-5">{item.notes}</p>}
              </a>
            ))}
          </div>
        </Card>
      )}

      {experience.sections.transport && sections.transport.length > 0 && (
        <Card title="Transport" icon={<MapPin size={16} style={{ color: portalColor }} />}>
          <div className="space-y-3">
            {sections.transport.map(item => (
              <div key={item.id} className="rounded-xl border border-gray-100 p-3">
                <p className="text-sm font-medium text-gray-800">{item.name}</p>
                <p className="mt-1 text-xs text-gray-500">{[item.departure_time ? new Date(item.departure_time).toLocaleString() : null, item.pickup_location, item.dropoff_location].filter(Boolean).join(' - ')}</p>
                {(item.driver_name || item.driver_phone) && <p className="mt-2 text-xs text-gray-500">Driver: {[item.driver_name, item.driver_phone].filter(Boolean).join(' - ')}</p>}
                {item.notes && <p className="mt-1 text-xs text-gray-500 leading-5">{item.notes}</p>}
              </div>
            ))}
          </div>
        </Card>
      )}

      {experience.sections.seating && sections.seating && (
        <Card title="Your seat" icon={<MapPin size={16} style={{ color: portalColor }} />}>
          <div className="rounded-xl border border-gray-100 p-3">
            <p className="text-sm font-medium text-gray-800">{sections.seating.table_name}</p>
            <p className="mt-1 text-xs text-gray-500">
              {[sections.seating.event_section, `Seat ${sections.seating.seat_label ?? sections.seating.seat_number}`].filter(Boolean).join(' - ')}
            </p>
            {sections.seating.notes && <p className="mt-2 text-xs text-gray-500 leading-5">{sections.seating.notes}</p>}
          </div>
        </Card>
      )}

      {experience.sections.live_feed && sections.live_updates.length > 0 && (
        <Card title="Live updates" icon={<Radio size={16} style={{ color: portalColor }} />}>
          <div className="space-y-3">
            {sections.live_updates.map(update => (
              <div key={update.id} className="rounded-xl bg-gray-50 p-3">
                <p className="text-sm font-medium text-gray-800">{update.title}</p>
                {update.body && <p className="mt-1 text-xs text-gray-500 leading-5">{update.body}</p>}
              </div>
            ))}
          </div>
        </Card>
      )}

      {experience.sections.registry && sections.registry.length > 0 && (
        <Card title="Registry" icon={<Gift size={16} style={{ color: portalColor }} />}>
          <div className="space-y-3">
            {sections.registry.map(item => (
              <div key={item.id} className="rounded-xl border border-gray-100 p-3">
                <p className="text-sm font-medium text-gray-800">{item.name}</p>
                {item.description && <p className="mt-1 text-xs text-gray-500 leading-5">{item.description}</p>}
                {(item.price || item.fund_goal) && <p className="mt-2 text-xs font-medium" style={{ color: portalColor }}>{item.currency ?? 'USD'} {item.price ?? item.fund_goal}</p>}
                <div className="mt-3 flex gap-2">
                  {item.store_url && <a href={item.store_url} className="flex-1 rounded-xl bg-gray-100 py-2 text-center text-xs font-semibold text-gray-700">View item</a>}
                  <button
                    type="button"
                    disabled={registrySavingId === item.id}
                    onClick={() => contributeRegistry(item)}
                    className="flex-1 rounded-xl py-2 text-xs font-semibold text-white disabled:opacity-50"
                    style={{ backgroundColor: portalColor }}
                  >
                    {registrySavingId === item.id ? 'Saving...' : item.type === 'cash_fund' ? 'Contribute' : 'Mark gifted'}
                  </button>
                </div>
              </div>
            ))}
            {registryMessage && <p className="text-xs text-gray-500">{registryMessage}</p>}
          </div>
        </Card>
      )}

      {experience.sections.gallery && sections.gallery.length > 0 && (
        <Card title="Gallery" icon={<ImageIcon size={16} style={{ color: portalColor }} />}>
          <div className="grid grid-cols-3 gap-2">
            {sections.gallery.map(item => <img key={item.id} src={item.thumbnail_url ?? item.url} alt={item.caption ?? 'Wedding gallery image'} className="aspect-square w-full rounded-xl object-cover bg-gray-100" />)}
          </div>
        </Card>
      )}

      {experience.sections.photo_uploads && (
        <Card title="Share a photo">
          <div className="space-y-3">
            <input type="file" accept="image/*,video/*" onChange={event => setPhotoFile(event.target.files?.[0] ?? null)} className="block w-full text-sm text-gray-600" />
            <input value={photoCaption} onChange={event => setPhotoCaption(event.target.value)} placeholder="Caption" className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm" />
            <button disabled={!photoFile || photoSaving} onClick={uploadPhoto} className="w-full py-3 rounded-xl text-sm font-semibold text-white disabled:opacity-50" style={{ backgroundColor: portalColor }}>
              {photoSaving ? 'Uploading...' : 'Upload for review'}
            </button>
            {photoMessage && <p className="text-xs text-gray-500">{photoMessage}</p>}
          </div>
        </Card>
      )}

      {preferences && (
        <section className="bg-white mx-4 mt-4 rounded-2xl p-5 shadow-sm">
          <h2 className="text-base font-semibold text-gray-800">Communication preferences</h2>
          <div className="mt-4 space-y-3">
            {[
              ['email_opt_out', 'Email updates'],
              ['sms_opt_out', 'SMS updates'],
              ['whatsapp_opt_out', 'WhatsApp updates'],
            ].map(([key, label]) => {
              const preferenceKey = key as keyof Pick<CommunicationPreferences, 'email_opt_out' | 'sms_opt_out' | 'whatsapp_opt_out'>;
              const isEnabled = !preferences[preferenceKey];
              return (
                <label key={key} className="flex items-center justify-between gap-4 text-sm text-gray-700">
                  <span>{label}</span>
                  <input
                    type="checkbox"
                    className="h-5 w-5 accent-[#285301]"
                    checked={isEnabled}
                    disabled={preferencesSaving}
                    onChange={event => savePreferences({ ...preferences, [preferenceKey]: !event.target.checked })}
                  />
                </label>
              );
            })}
          </div>
          <p className="mt-3 text-xs text-gray-400">
            {preferencesSaving ? 'Saving...' : preferencesError ? preferencesError : preferencesSaved ? 'Preferences saved.' : 'Only wedding-related updates are sent.'}
          </p>
        </section>
      )}
    </div>
  );
}

function Card({ title, icon, children }: { title: string; icon?: ReactNode; children: ReactNode }) {
  return (
    <section className="bg-white mx-4 mt-4 rounded-2xl p-5 shadow-sm">
      <div className="flex items-center gap-2 mb-4">
        {icon}
        <h2 className="text-base font-semibold text-gray-800">{title}</h2>
      </div>
      {children}
    </section>
  );
}

function InfoRow({ icon, text, muted = false }: { icon: ReactNode; text: string; muted?: boolean }) {
  return (
    <div className="flex items-center gap-3 text-sm">
      <span className="flex-shrink-0">{icon}</span>
      <span className={muted ? 'text-gray-500' : 'text-gray-700'}>{text}</span>
    </div>
  );
}
