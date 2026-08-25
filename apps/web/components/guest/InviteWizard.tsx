'use client';

/* eslint-disable @next/next/no-img-element */

import { useEffect, useState } from 'react';
import type { FormEvent, ReactNode } from 'react';
import {
  ArrowLeft,
  ArrowRight,
  Calendar,
  Check,
  Gift,
  Heart,
  Lock,
  Mail,
  MapPin,
  MessageSquare,
  Music,
  Pencil,
  Phone,
  Plane,
  User,
  Users,
  Utensils,
} from 'lucide-react';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';
const SUPPORT_EMAIL = 'hello@udowedding.com';

const STEP_LABELS = ['Guest Details', 'RSVP', 'Your Preferences', 'Additional Info', 'All Set!'];

const COUNTRY_CODES = [
  { label: '🇯🇲 +1 876', value: '+1876' },
  { label: '🇺🇸 +1', value: '+1' },
  { label: '🇨🇦 +1', value: '+1' },
  { label: '🇬🇧 +44', value: '+44' },
  { label: '🌐 Other', value: '' },
];

const MEAL_OPTIONS = ['Chicken', 'Fish', 'Vegetarian', 'Vegan'];

type InviteSummary = {
  wedding: {
    couple_name_primary: string;
    couple_name_secondary: string | null;
    event_date: string | null;
    city: string | null;
    country: string | null;
  };
};

type GuestShowResponse = {
  guest: {
    first_name: string;
    last_name: string;
    email: string | null;
    phone: string | null;
    attending_status: 'pending' | 'yes' | 'no';
    plus_one_allowed: boolean;
    plus_one_count: number;
    plus_one_name: string | null;
    plus_one_email: string | null;
    meal_preference: string | null;
    dietary_note: string | null;
    song_request: string | null;
    wants_accommodation: boolean | null;
    arrival_date: string | null;
    arrival_time: string | null;
    arrival_airport: string | null;
    notes: string | null;
  };
  experience: {
    sections: {
      rsvp: boolean;
      meal_selection: boolean;
      plus_one: boolean;
      registry: boolean;
    };
  };
  wedding: InviteSummary['wedding'];
};

type FormState = {
  fullName: string;
  email: string;
  dialCode: string;
  localPhone: string;
  attendingStatus: 'yes' | 'no' | null;
  hasPlusOne: boolean;
  plusOneName: string;
  plusOneEmail: string;
  mealPreference: string;
  dietaryNote: string;
  songRequest: string;
  wantsAccommodation: boolean | null;
  showArrivalForm: boolean;
  arrivalDate: string;
  arrivalTime: string;
  arrivalAirport: string;
  showNotesForm: boolean;
  notes: string;
};

const emptyForm: FormState = {
  fullName: '',
  email: '',
  dialCode: '+1876',
  localPhone: '',
  attendingStatus: null,
  hasPlusOne: false,
  plusOneName: '',
  plusOneEmail: '',
  mealPreference: '',
  dietaryNote: '',
  songRequest: '',
  wantsAccommodation: null,
  showArrivalForm: false,
  arrivalDate: '',
  arrivalTime: '',
  arrivalAirport: '',
  showNotesForm: false,
  notes: '',
};

export default function InviteWizard({ code }: { code: string }) {
  const [summary, setSummary] = useState<InviteSummary | null>(null);
  const [summaryError, setSummaryError] = useState(false);
  const [step, setStep] = useState(1);
  const [token, setToken] = useState<string | null>(null);
  const [guestData, setGuestData] = useState<GuestShowResponse | null>(null);
  const [form, setForm] = useState<FormState>(emptyForm);
  const [identifyError, setIdentifyError] = useState<string | null>(null);
  const [ambiguous, setAmbiguous] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);

  const storageKey = `udo_invite_${code}_token`;

  useEffect(() => {
    fetch(`${API_BASE}/invite/${code}`)
      .then((res) => (res.ok ? res.json() : Promise.reject()))
      .then((data: InviteSummary) => setSummary(data))
      .catch(() => setSummaryError(true));
  }, [code]);

  useEffect(() => {
    const saved = typeof window !== 'undefined' ? sessionStorage.getItem(storageKey) : null;
    if (!saved) return;
    fetch(`${API_BASE}/g/${saved}`)
      .then((res) => (res.ok ? res.json() : Promise.reject()))
      .then((data: GuestShowResponse) => {
        setToken(saved);
        hydrateFromGuest(data);
        setStep(2);
      })
      .catch(() => sessionStorage.removeItem(storageKey));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function hydrateFromGuest(data: GuestShowResponse) {
    setGuestData(data);
    setForm((prev) => ({
      ...prev,
      fullName: `${data.guest.first_name} ${data.guest.last_name}`.trim(),
      email: data.guest.email ?? '',
      localPhone: data.guest.phone ?? prev.localPhone,
      attendingStatus: data.guest.attending_status === 'yes' || data.guest.attending_status === 'no' ? data.guest.attending_status : null,
      hasPlusOne: Boolean(data.guest.plus_one_name || data.guest.plus_one_count > 0),
      plusOneName: data.guest.plus_one_name ?? '',
      plusOneEmail: data.guest.plus_one_email ?? '',
      mealPreference: data.guest.meal_preference ?? '',
      dietaryNote: data.guest.dietary_note ?? '',
      songRequest: data.guest.song_request ?? '',
      wantsAccommodation: data.guest.wants_accommodation,
      arrivalDate: data.guest.arrival_date ?? '',
      arrivalTime: data.guest.arrival_time ?? '',
      arrivalAirport: data.guest.arrival_airport ?? '',
      notes: data.guest.notes ?? '',
    }));
  }

  async function handleIdentify(e: FormEvent) {
    e.preventDefault();
    setIdentifyError(null);
    setAmbiguous(false);
    setSubmitting(true);
    try {
      const res = await fetch(`${API_BASE}/invite/${code}/identify`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ full_name: form.fullName, email: form.email || undefined }),
      });
      const body = await res.json();
      if (!res.ok) {
        setIdentifyError(body.message ?? 'Something went wrong. Please try again.');
        setAmbiguous(Boolean(body.ambiguous));
        return;
      }
      sessionStorage.setItem(storageKey, body.token);
      setToken(body.token);
      const showRes = await fetch(`${API_BASE}/g/${body.token}`);
      const showData: GuestShowResponse = await showRes.json();
      hydrateFromGuest(showData);
      setStep(2);
    } catch {
      setIdentifyError('We could not reach the server. Please check your connection and try again.');
    } finally {
      setSubmitting(false);
    }
  }

  async function submitRsvp(extra: Record<string, unknown> = {}) {
    if (!token) return;
    await fetch(`${API_BASE}/g/${token}/rsvp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ attending_status: form.attendingStatus ?? 'yes', ...extra }),
    });
  }

  async function submitPreferences(extra: Record<string, unknown> = {}) {
    if (!token) return;
    await fetch(`${API_BASE}/g/${token}/preferences`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(extra),
    });
  }

  async function handleStep2Submit(e: FormEvent) {
    e.preventDefault();
    setSubmitError(null);
    setSubmitting(true);
    try {
      const phone = form.localPhone ? `${form.dialCode} ${form.localPhone}` : undefined;
      await Promise.all([
        guestData?.experience.sections.rsvp
          ? submitRsvp({ plus_one_count: form.hasPlusOne ? 1 : 0 })
          : Promise.resolve(),
        submitPreferences({
          phone,
          plus_one_name: form.hasPlusOne ? form.plusOneName || undefined : undefined,
          plus_one_email: form.hasPlusOne ? form.plusOneEmail || undefined : undefined,
        }),
      ]);
      setStep(3);
    } catch {
      setSubmitError('We could not save your details. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStep3Submit(e: FormEvent) {
    e.preventDefault();
    setSubmitError(null);
    setSubmitting(true);
    try {
      await Promise.all([
        guestData?.experience.sections.rsvp
          ? submitRsvp({
              meal_preference: guestData.experience.sections.meal_selection ? form.mealPreference || undefined : undefined,
              dietary_note: form.dietaryNote || undefined,
            })
          : Promise.resolve(),
        submitPreferences({ song_request: form.songRequest || undefined }),
      ]);
      setStep(4);
    } catch {
      setSubmitError('We could not save your preferences. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  async function handleStep4Submit(e: FormEvent) {
    e.preventDefault();
    setSubmitError(null);
    setSubmitting(true);
    try {
      await submitPreferences({
        wants_accommodation: form.wantsAccommodation ?? undefined,
        arrival_date: form.arrivalDate || undefined,
        arrival_time: form.arrivalTime || undefined,
        arrival_airport: form.arrivalAirport || undefined,
        notes: form.notes || undefined,
      });
      setStep(5);
    } catch {
      setSubmitError('We could not save your details. Please try again.');
    } finally {
      setSubmitting(false);
    }
  }

  const wedding = guestData?.wedding ?? summary?.wedding ?? null;
  const couple = wedding
    ? wedding.couple_name_secondary
      ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
      : wedding.couple_name_primary
    : '';
  const dateLabel = wedding?.event_date
    ? new Date(`${wedding.event_date}T00:00:00`).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
    : '';
  const locationLabel = wedding ? [wedding.city, wedding.country].filter(Boolean).join(', ') : '';

  if (summaryError) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#fbf7f4] p-6 text-center">
        <div>
          <Heart className="mx-auto mb-4 text-[#9b526d]" size={42} />
          <h1 className="font-serif text-3xl text-[#2d2729]">Invitation not found</h1>
          <p className="mt-2 text-sm text-[#6f6768]">Please double-check the invite code, or contact the couple for a new link.</p>
        </div>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-[#fbf7f4] text-[#2d2729]">
      <header
        className="relative overflow-hidden bg-cover bg-center px-6 py-7 md:px-10"
        style={{ backgroundImage: 'linear-gradient(90deg, rgba(255,255,255,.97) 0%, rgba(255,255,255,.93) 55%, rgba(255,255,255,.55) 100%), url(/guest-portal/rose.jpeg)' }}
      >
        <div className="font-serif text-3xl leading-6 tracking-tight">
          udo<div className="font-sans text-[8px] uppercase tracking-[0.32em]">weddings</div>
        </div>
        <div className="mx-auto mt-6 max-w-2xl text-center">
          <div className="flex items-center justify-center gap-4 text-[10px] uppercase tracking-[0.3em] text-[#9b6a75]">
            <span className="h-px w-8 bg-[#d9b9bd]" />
            <span className="font-serif text-2xl normal-case tracking-normal text-[#2d2729] sm:text-3xl">{couple || 'Loading…'}</span>
            <span className="h-px w-8 bg-[#d9b9bd]" />
          </div>
          {(dateLabel || locationLabel) && (
            <p className="mt-3 text-xs uppercase tracking-[0.28em] text-[#4f4648]">
              {dateLabel}
              {dateLabel && locationLabel ? ' · ' : ''}
              {locationLabel}
            </p>
          )}
        </div>
      </header>

      <div className="mx-auto max-w-4xl px-6 py-8">
        <StepIndicator current={step} />
      </div>

      <div className="mx-auto grid max-w-6xl grid-cols-1 gap-6 px-6 pb-16 lg:grid-cols-[1fr_320px]">
        <section>
          {step === 1 && (
            <Step1
              form={form}
              setForm={setForm}
              onSubmit={handleIdentify}
              submitting={submitting}
              error={identifyError}
              ambiguous={ambiguous}
            />
          )}
          {step === 2 && guestData && (
            <Step2
              form={form}
              setForm={setForm}
              onSubmit={handleStep2Submit}
              onEdit={() => {
                sessionStorage.removeItem(storageKey);
                setToken(null);
                setGuestData(null);
                setStep(1);
              }}
              submitting={submitting}
              error={submitError}
              plusOneEnabled={guestData.experience.sections.plus_one && guestData.guest.plus_one_allowed}
              rsvpEnabled={guestData.experience.sections.rsvp}
            />
          )}
          {step === 3 && guestData && (
            <Step3
              form={form}
              setForm={setForm}
              onSubmit={handleStep3Submit}
              onBack={() => setStep(2)}
              submitting={submitting}
              error={submitError}
              mealEnabled={guestData.experience.sections.meal_selection}
              required={form.attendingStatus !== 'no'}
            />
          )}
          {step === 4 && guestData && (
            <Step4
              form={form}
              setForm={setForm}
              onSubmit={handleStep4Submit}
              onBack={() => setStep(3)}
              submitting={submitting}
              error={submitError}
              registryEnabled={guestData.experience.sections.registry}
              token={token}
              couple={couple}
              dateLabel={dateLabel}
              locationLabel={locationLabel}
            />
          )}
          {step === 5 && <Step5 token={token} couple={couple} />}
        </section>

        {step < 5 && <Sidebar step={step} token={token} couple={couple} dateLabel={dateLabel} locationLabel={locationLabel} />}
      </div>
    </main>
  );
}

function StepIndicator({ current }: { current: number }) {
  return (
    <div className="flex items-center justify-center">
      {STEP_LABELS.map((label, index) => {
        const stepNumber = index + 1;
        const isDone = stepNumber < current;
        const isActive = stepNumber === current;
        return (
          <div key={label} className="flex items-center">
            <div className="flex flex-col items-center gap-2">
              <div
                className={`flex h-9 w-9 items-center justify-center rounded-full text-sm font-semibold ${
                  isDone
                    ? 'bg-[#8c5367] text-white'
                    : isActive
                      ? 'border-2 border-[#8c5367] bg-white text-[#8c5367]'
                      : 'border border-[#eadcda] bg-white text-[#a8a09f]'
                }`}
              >
                {isDone ? <Check size={16} /> : stepNumber}
              </div>
              <span className={`hidden text-[10px] uppercase tracking-wide sm:block ${isActive ? 'text-[#8c5367]' : 'text-[#a8a09f]'}`}>
                {label}
              </span>
            </div>
            {stepNumber < STEP_LABELS.length && (
              <div className={`mx-2 h-px w-8 sm:w-16 ${isDone ? 'bg-[#8c5367]' : 'bg-[#eadcda]'}`} />
            )}
          </div>
        );
      })}
    </div>
  );
}

function QuoteCard({ text = '"Two souls, one heart, a lifetime of love."' }: { text?: string }) {
  return (
    <div className="rounded-xl border border-[#eadcda] bg-white p-6">
      <Heart className="text-[#c08c96]" size={22} />
      <p className="mt-4 font-serif text-lg leading-6 text-[#2d2729]">{text}</p>
    </div>
  );
}

function Sidebar({ step, token, couple, dateLabel, locationLabel }: { step: number; token: string | null; couple: string; dateLabel: string; locationLabel: string }) {
  const items = [
    { icon: <Check size={16} />, label: 'RSVP to the wedding' },
    { icon: <Users size={16} />, label: 'Choose your meal' },
    { icon: <Plane size={16} />, label: 'Share travel plans' },
    { icon: <Calendar size={16} />, label: 'Get all the details' },
  ];

  if (step === 4 && token) {
    return (
      <aside className="space-y-6">
        <ProgressCard step={step} />
        <div className="overflow-hidden rounded-xl border border-[#eadcda] bg-white">
          <div
            className="relative flex h-32 items-end bg-cover bg-center p-4 text-white"
            style={{ backgroundImage: 'linear-gradient(0deg, rgba(45,39,41,.75), rgba(45,39,41,.15)), url(/guest-portal/rose.jpeg)' }}
          >
            <div>
              <p className="text-[10px] uppercase tracking-[0.28em]">You&apos;re Invited</p>
              <p className="font-serif text-lg">{couple}</p>
            </div>
          </div>
          <div className="p-4 text-xs text-[#6f6768]">
            {dateLabel}
            {locationLabel ? ` · ${locationLabel}` : ''}
          </div>
        </div>
        <div className="rounded-xl border border-[#eadcda] bg-white p-6 text-center">
          <p className="text-sm font-semibold text-[#2d2729]">Need Help?</p>
          <p className="mt-2 text-xs text-[#6f6768]">Our team is here to help you with anything.</p>
          <a
            href={`mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(`Invitation help - ${couple}`)}`}
            className="mt-4 inline-flex items-center gap-2 rounded-lg border border-[#a76b80] px-5 py-2.5 text-sm font-semibold text-[#8c5367]"
          >
            <MessageSquare size={16} />
            Contact Support
          </a>
        </div>
      </aside>
    );
  }

  if (step >= 3) {
    return (
      <aside className="space-y-6">
        <ProgressCard step={step} />
        <QuoteCard />
      </aside>
    );
  }

  return (
    <aside className="space-y-6">
      <div className="rounded-xl border border-[#eadcda] bg-white p-6">
        <p className="font-serif text-xl">{step === 1 ? "What's Next?" : 'Your Wedding Experience'}</p>
        <ul className="mt-5 space-y-4">
          {items.map((item) => (
            <li key={item.label} className="flex items-center gap-3 text-sm text-[#4f4648]">
              <span className="flex h-8 w-8 flex-none items-center justify-center rounded-full bg-[#f4ece9] text-[#9b526d]">{item.icon}</span>
              {item.label}
            </li>
          ))}
        </ul>
      </div>
      <QuoteCard text='"How wonderful life is now you&apos;re in the world." — Louis Armstrong' />
    </aside>
  );
}

function ProgressCard({ step }: { step: number }) {
  return (
    <div className="rounded-xl border border-[#eadcda] bg-white p-6">
      <p className="font-serif text-xl">Your Progress</p>
      <ul className="mt-5 space-y-4">
        {STEP_LABELS.map((label, index) => {
          const stepNumber = index + 1;
          const isDone = stepNumber < step;
          const isCurrent = stepNumber === step;
          return (
            <li key={label} className="flex items-center gap-3 text-sm">
              <span
                className={`flex h-7 w-7 flex-none items-center justify-center rounded-full text-xs font-semibold ${
                  isDone ? 'bg-[#8c5367] text-white' : isCurrent ? 'border-2 border-[#8c5367] text-[#8c5367]' : 'border border-[#eadcda] text-[#a8a09f]'
                }`}
              >
                {isDone ? <Check size={13} /> : stepNumber}
              </span>
              <span className={isCurrent ? 'font-semibold text-[#2d2729]' : 'text-[#6f6768]'}>{label}</span>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function FieldLabel({ children }: { children: ReactNode }) {
  return <label className="mb-2 block text-[11px] font-semibold uppercase tracking-[0.14em] text-[#6f6768]">{children}</label>;
}

function TextField({
  icon,
  ...props
}: { icon?: ReactNode } & React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <div className="relative">
      {icon && <span className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[#a8a09f]">{icon}</span>}
      <input
        {...props}
        className={`w-full rounded-lg border border-[#eadcda] bg-white py-3 text-sm text-[#2d2729] placeholder:text-[#c4bcbc] focus:border-[#8c5367] focus:outline-none ${icon ? 'pl-11 pr-4' : 'px-4'}`}
      />
    </div>
  );
}

function Step1({
  form,
  setForm,
  onSubmit,
  submitting,
  error,
  ambiguous,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  onSubmit: (e: FormEvent) => void;
  submitting: boolean;
  error: string | null;
  ambiguous: boolean;
}) {
  return (
    <div>
      <h1 className="font-serif text-4xl text-[#2d2729]">Let&apos;s Get Started</h1>
      <p className="mt-2 text-sm text-[#6f6768]">Please enter your details to access your personal wedding experience.</p>

      <div className="mt-8 grid grid-cols-1 overflow-hidden rounded-xl border border-[#eadcda] bg-white md:grid-cols-[0.9fr_1.1fr]">
        <div
          className="hidden bg-cover bg-center md:block"
          style={{ backgroundImage: 'linear-gradient(0deg, rgba(255,255,255,0), rgba(255,255,255,.1)), url(/guest-portal/rose.jpeg)' }}
        />
        <form onSubmit={onSubmit} className="p-8">
          <p className="font-serif text-2xl">Who are we celebrating with?</p>
          <p className="mt-1 text-sm text-[#6f6768]">We can&apos;t wait to celebrate together!</p>

          <div className="mt-6">
            <FieldLabel>Full Name</FieldLabel>
            <TextField
              icon={<User size={17} />}
              placeholder="e.g. Emma Wilson"
              required
              value={form.fullName}
              onChange={(e) => setForm((prev) => ({ ...prev, fullName: e.target.value }))}
            />
          </div>

          <div className="mt-5">
            <FieldLabel>Email Address (Optional{ambiguous ? ' — required to confirm your identity' : ''})</FieldLabel>
            <TextField
              icon={<Mail size={17} />}
              type="email"
              placeholder="e.g. emma@email.com"
              value={form.email}
              onChange={(e) => setForm((prev) => ({ ...prev, email: e.target.value }))}
            />
            <p className="mt-2 text-xs text-[#8a8081]">We&apos;ll use this to send you updates about the wedding.</p>
          </div>

          {error && <p className="mt-4 rounded-lg bg-[#fbeceb] px-4 py-3 text-sm text-[#a13d3d]">{error}</p>}

          <button
            type="submit"
            disabled={submitting || !form.fullName.trim()}
            className="mt-6 flex w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-6 py-3.5 text-sm font-semibold text-white disabled:opacity-60"
          >
            {submitting ? 'Please wait…' : 'Continue'}
            <ArrowRight size={16} />
          </button>
        </form>
      </div>

      <p className="mt-4 flex items-center justify-center gap-2 text-xs text-[#8a8081]">
        <Lock size={13} />
        Your information is private and secure.
      </p>
    </div>
  );
}

function Step2({
  form,
  setForm,
  onSubmit,
  onEdit,
  submitting,
  error,
  plusOneEnabled,
  rsvpEnabled,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  onSubmit: (e: FormEvent) => void;
  onEdit: () => void;
  submitting: boolean;
  error: string | null;
  plusOneEnabled: boolean;
  rsvpEnabled: boolean;
}) {
  const initials = form.fullName
    .split(' ')
    .filter(Boolean)
    .map((part) => part[0]?.toUpperCase())
    .slice(0, 2)
    .join('');

  return (
    <div>
      <h1 className="font-serif text-4xl text-[#2d2729]">Please Confirm Your Details</h1>
      <p className="mt-2 text-sm text-[#6f6768]">We already have some of your information. Just confirm it&apos;s correct and add any additional guests.</p>

      <form onSubmit={onSubmit} className="mt-8 rounded-xl border border-[#eadcda] bg-white p-8">
        <div className="flex items-center gap-4 border-b border-[#f0e4e1] pb-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-full bg-gradient-to-br from-[#d7a7a3] to-[#9b526d] text-sm font-semibold text-white">
            {initials || <User size={18} />}
          </div>
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-[#2d2729]">{form.fullName}</p>
            {form.email && <p className="truncate text-sm text-[#6f6768]">{form.email}</p>}
          </div>
          <button type="button" onClick={onEdit} className="flex items-center gap-1 text-sm font-medium text-[#8c5367]">
            <Pencil size={14} />
            Edit
          </button>
        </div>

        {rsvpEnabled && (
          <div className="mt-6">
            <FieldLabel>Will You Be Attending?</FieldLabel>
            <div className="flex gap-3">
              {(['yes', 'no'] as const).map((value) => (
                <button
                  key={value}
                  type="button"
                  onClick={() => setForm((prev) => ({ ...prev, attendingStatus: value }))}
                  className={`flex-1 rounded-lg border px-4 py-3 text-sm font-semibold ${
                    form.attendingStatus === value
                      ? 'border-[#8c5367] bg-[#f4ece9] text-[#8c5367]'
                      : 'border-[#eadcda] text-[#6f6768]'
                  }`}
                >
                  {value === 'yes' ? "Joyfully Accept" : "Regretfully Decline"}
                </button>
              ))}
            </div>
          </div>
        )}

        <div className="mt-6">
          <FieldLabel>Your Phone Number</FieldLabel>
          <div className="flex gap-2">
            <select
              value={form.dialCode}
              onChange={(e) => setForm((prev) => ({ ...prev, dialCode: e.target.value }))}
              className="rounded-lg border border-[#eadcda] bg-white px-3 py-3 text-sm text-[#2d2729] focus:border-[#8c5367] focus:outline-none"
            >
              {COUNTRY_CODES.map((c) => (
                <option key={c.label} value={c.value}>
                  {c.label}
                </option>
              ))}
            </select>
            <div className="flex-1">
              <TextField
                icon={<Phone size={17} />}
                type="tel"
                placeholder="123-4567"
                value={form.localPhone}
                onChange={(e) => setForm((prev) => ({ ...prev, localPhone: e.target.value }))}
              />
            </div>
          </div>
        </div>

        {plusOneEnabled && (
          <div className="mt-6 rounded-lg border border-[#eadcda] p-5">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-[#2d2729]">Bringing a Plus One?</p>
                <p className="mt-1 text-xs text-[#6f6768]">Add their details below so we can include them.</p>
              </div>
              <button
                type="button"
                role="switch"
                aria-checked={form.hasPlusOne}
                onClick={() => setForm((prev) => ({ ...prev, hasPlusOne: !prev.hasPlusOne }))}
                className={`relative h-6 w-11 flex-none rounded-full transition-colors ${form.hasPlusOne ? 'bg-[#8c5367]' : 'bg-[#eadcda]'}`}
              >
                <span className={`absolute top-0.5 h-5 w-5 rounded-full bg-white transition-transform ${form.hasPlusOne ? 'translate-x-5' : 'translate-x-0.5'}`} />
              </button>
            </div>

            {form.hasPlusOne && (
              <div className="mt-5 space-y-4">
                <div>
                  <FieldLabel>Plus One Full Name</FieldLabel>
                  <TextField
                    icon={<Users size={17} />}
                    placeholder="e.g. James Wilson"
                    value={form.plusOneName}
                    onChange={(e) => setForm((prev) => ({ ...prev, plusOneName: e.target.value }))}
                  />
                </div>
                <div>
                  <FieldLabel>Plus One Email</FieldLabel>
                  <TextField
                    icon={<Mail size={17} />}
                    type="email"
                    placeholder="e.g. james@email.com"
                    value={form.plusOneEmail}
                    onChange={(e) => setForm((prev) => ({ ...prev, plusOneEmail: e.target.value }))}
                  />
                </div>
              </div>
            )}
          </div>
        )}

        {error && <p className="mt-4 rounded-lg bg-[#fbeceb] px-4 py-3 text-sm text-[#a13d3d]">{error}</p>}

        <button
          type="submit"
          disabled={submitting || (rsvpEnabled && !form.attendingStatus)}
          className="mt-7 flex w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-6 py-3.5 text-sm font-semibold text-white disabled:opacity-60"
        >
          {submitting ? 'Saving…' : 'Save & Continue'}
          <ArrowRight size={16} />
        </button>
      </form>
    </div>
  );
}

function Step3({
  form,
  setForm,
  onSubmit,
  onBack,
  submitting,
  error,
  mealEnabled,
  required,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  onSubmit: (e: FormEvent) => void;
  onBack: () => void;
  submitting: boolean;
  error: string | null;
  mealEnabled: boolean;
  required: boolean;
}) {
  return (
    <div>
      <h1 className="font-serif text-4xl text-[#2d2729]">Tell Us About Your Preferences</h1>
      <p className="mt-2 text-sm text-[#6f6768]">Your preferences help us create the best experience for you.</p>

      <form onSubmit={onSubmit} className="mt-8 rounded-xl border border-[#eadcda] bg-white p-8">
        {mealEnabled && (
          <div>
            <div className="flex items-center gap-2">
              <FieldLabel>Meal Preference</FieldLabel>
              {required && <span className="mb-2 rounded-full bg-[#f4ece9] px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wide text-[#8c5367]">Required</span>}
            </div>
            <div className="grid grid-cols-2 gap-3">
              {MEAL_OPTIONS.map((option) => (
                <button
                  key={option}
                  type="button"
                  onClick={() => setForm((prev) => ({ ...prev, mealPreference: option }))}
                  className={`rounded-lg border px-4 py-3 text-sm font-semibold ${
                    form.mealPreference === option ? 'border-[#8c5367] bg-[#f4ece9] text-[#8c5367]' : 'border-[#eadcda] text-[#6f6768]'
                  }`}
                >
                  {option}
                </button>
              ))}
            </div>
          </div>
        )}

        <div className="mt-6">
          <FieldLabel>Dietary Restrictions or Allergies (Optional)</FieldLabel>
          <TextField
            icon={<Utensils size={17} />}
            placeholder="e.g. Nut allergy, gluten-free"
            value={form.dietaryNote}
            onChange={(e) => setForm((prev) => ({ ...prev, dietaryNote: e.target.value }))}
          />
        </div>

        <div className="mt-5">
          <FieldLabel>Any Song Requests? (Optional)</FieldLabel>
          <TextField
            icon={<Music size={17} />}
            placeholder="e.g. Uptown Funk — Bruno Mars"
            value={form.songRequest}
            onChange={(e) => setForm((prev) => ({ ...prev, songRequest: e.target.value }))}
          />
        </div>

        {error && <p className="mt-4 rounded-lg bg-[#fbeceb] px-4 py-3 text-sm text-[#a13d3d]">{error}</p>}

        <div className="mt-7 flex gap-3">
          <button type="button" onClick={onBack} className="flex items-center gap-2 rounded-lg border border-[#eadcda] px-6 py-3.5 text-sm font-semibold text-[#6f6768]">
            <ArrowLeft size={16} />
            Back
          </button>
          <button
            type="submit"
            disabled={submitting || (mealEnabled && required && !form.mealPreference)}
            className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-6 py-3.5 text-sm font-semibold text-white disabled:opacity-60"
          >
            {submitting ? 'Saving…' : 'Continue'}
            <ArrowRight size={16} />
          </button>
        </div>
      </form>
    </div>
  );
}

function Step4({
  form,
  setForm,
  onSubmit,
  onBack,
  submitting,
  error,
  registryEnabled,
  token,
  couple,
}: {
  form: FormState;
  setForm: React.Dispatch<React.SetStateAction<FormState>>;
  onSubmit: (e: FormEvent) => void;
  onBack: () => void;
  submitting: boolean;
  error: string | null;
  registryEnabled: boolean;
  token: string | null;
  couple: string;
  dateLabel: string;
  locationLabel: string;
}) {
  return (
    <div>
      <h1 className="font-serif text-4xl text-[#2d2729]">A Few Final Details</h1>
      <p className="mt-2 text-sm text-[#6f6768]">Help us make your experience seamless and memorable.</p>

      <form onSubmit={onSubmit} className="mt-8 space-y-5 rounded-xl border border-[#eadcda] bg-white p-8">
        <div>
          <p className="text-sm font-semibold text-[#2d2729]">Accommodation (Optional)</p>
          <p className="mt-1 text-xs text-[#6f6768]">Would you like to book accommodation through our room block?</p>
          <div className="mt-3 flex gap-3">
            {([true, false] as const).map((value) => (
              <button
                key={String(value)}
                type="button"
                onClick={() => setForm((prev) => ({ ...prev, wantsAccommodation: value }))}
                className={`rounded-full border px-6 py-2 text-sm font-semibold ${
                  form.wantsAccommodation === value ? 'border-[#8c5367] bg-[#f4ece9] text-[#8c5367]' : 'border-[#eadcda] text-[#6f6768]'
                }`}
              >
                {value ? 'Yes' : 'No'}
              </button>
            ))}
          </div>
        </div>

        <div className="border-t border-[#f0e4e1] pt-5">
          <p className="text-sm font-semibold text-[#2d2729]">Arrival Information (Optional)</p>
          <p className="mt-1 text-xs text-[#6f6768]">Let us know your arrival details for a smoother experience.</p>
          {!form.showArrivalForm ? (
            <button
              type="button"
              onClick={() => setForm((prev) => ({ ...prev, showArrivalForm: true }))}
              className="mt-3 flex items-center gap-2 text-sm font-semibold text-[#8c5367]"
            >
              <Plane size={16} />
              Add Arrival Info
              <ArrowRight size={14} />
            </button>
          ) : (
            <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-3">
              <TextField
                icon={<Calendar size={16} />}
                type="date"
                value={form.arrivalDate}
                onChange={(e) => setForm((prev) => ({ ...prev, arrivalDate: e.target.value }))}
              />
              <input
                type="time"
                value={form.arrivalTime}
                onChange={(e) => setForm((prev) => ({ ...prev, arrivalTime: e.target.value }))}
                className="rounded-lg border border-[#eadcda] bg-white px-4 py-3 text-sm text-[#2d2729] focus:border-[#8c5367] focus:outline-none"
              />
              <TextField
                icon={<MapPin size={16} />}
                placeholder="Airport"
                value={form.arrivalAirport}
                onChange={(e) => setForm((prev) => ({ ...prev, arrivalAirport: e.target.value }))}
              />
            </div>
          )}
        </div>

        <div className="border-t border-[#f0e4e1] pt-5">
          <p className="text-sm font-semibold text-[#2d2729]">Anything Else We Should Know? (Optional)</p>
          <p className="mt-1 text-xs text-[#6f6768]">Add any additional notes or requests for the couple.</p>
          {!form.showNotesForm ? (
            <button
              type="button"
              onClick={() => setForm((prev) => ({ ...prev, showNotesForm: true }))}
              className="mt-3 flex items-center gap-2 text-sm font-semibold text-[#8c5367]"
            >
              <MessageSquare size={16} />
              Add Note
              <ArrowRight size={14} />
            </button>
          ) : (
            <textarea
              value={form.notes}
              onChange={(e) => setForm((prev) => ({ ...prev, notes: e.target.value }))}
              rows={3}
              placeholder="Anything you'd like the couple to know…"
              className="mt-3 w-full rounded-lg border border-[#eadcda] bg-white px-4 py-3 text-sm text-[#2d2729] placeholder:text-[#c4bcbc] focus:border-[#8c5367] focus:outline-none"
            />
          )}
        </div>

        {registryEnabled && (
          <div className="border-t border-[#f0e4e1] pt-5">
            <p className="text-sm font-semibold text-[#2d2729]">Gifts (Optional)</p>
            <p className="mt-1 text-xs text-[#6f6768]">View our registry or contribute to our honeymoon fund.</p>
            {token && (
              <a href={`/g/${token}#registry`} target="_blank" rel="noreferrer" className="mt-3 inline-flex items-center gap-2 text-sm font-semibold text-[#8c5367]">
                <Gift size={16} />
                View Options
                <ArrowRight size={14} />
              </a>
            )}
          </div>
        )}

        {error && <p className="rounded-lg bg-[#fbeceb] px-4 py-3 text-sm text-[#a13d3d]">{error}</p>}

        <div className="flex gap-3 pt-2">
          <button type="button" onClick={onBack} className="flex items-center gap-2 rounded-lg border border-[#eadcda] px-6 py-3.5 text-sm font-semibold text-[#6f6768]">
            <ArrowLeft size={16} />
            Back
          </button>
          <button
            type="submit"
            disabled={submitting}
            className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-6 py-3.5 text-sm font-semibold text-white disabled:opacity-60"
          >
            {submitting ? 'Saving…' : 'Continue'}
            <ArrowRight size={16} />
          </button>
        </div>
      </form>

      <p className="mt-3 text-center text-xs text-[#8a8081]">Celebrating with {couple || 'the couple'} — thank you for taking the time.</p>
    </div>
  );
}

function Step5({ token, couple }: { token: string | null; couple: string }) {
  return (
    <div className="rounded-xl border border-[#eadcda] bg-white p-12 text-center">
      <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-[#f4ece9] text-[#8c5367]">
        <Check size={30} />
      </div>
      <h1 className="mt-6 font-serif text-4xl text-[#2d2729]">All Set!</h1>
      <p className="mx-auto mt-3 max-w-md text-sm text-[#6f6768]">
        Thank you for sharing your details with us. We can&apos;t wait to celebrate {couple ? `with you at ${couple}'s wedding` : 'with you'}!
      </p>
      {token && (
        <a
          href={`/g/${token}`}
          className="mt-8 inline-flex items-center gap-2 rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-8 py-3.5 text-sm font-semibold text-white"
        >
          View Your Full Wedding Experience
          <ArrowRight size={16} />
        </a>
      )}
    </div>
  );
}
