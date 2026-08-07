'use client';

/* eslint-disable @next/next/no-img-element */

import { useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import {
  Bed,
  Bell,
  CalendarDays,
  Camera,
  Car,
  ChevronDown,
  Gift,
  Heart,
  HelpCircle,
  Mail,
  Map,
  MessageCircle,
  Plane,
  Utensils,
} from 'lucide-react';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

type Wedding = {
  title: string | null;
  couple_name_primary: string;
  couple_name_secondary: string | null;
  event_date: string | null;
  city: string | null;
  country: string | null;
  venue: string | null;
  venue_address: string | null;
  rsvp_deadline: string | null;
  hashtag?: string | null;
};

type Experience = {
  published: boolean;
  welcome_message: string | null;
  cover_image_url: string | null;
  theme_color: string;
  sections: {
    schedule: boolean;
    venue_map: boolean;
    accommodation: boolean;
    transport: boolean;
    registry: boolean;
    gallery: boolean;
    meal_selection: boolean;
    rsvp: boolean;
    messages: boolean;
  };
};

type PortalData = {
  portal_url: string;
  experience: Experience;
  wedding: Wedding;
  portal_alerts: Array<{
    id: string;
    type: string;
    title: string;
    body: string | null;
    target: string | null;
    trigger_at: string | null;
  }>;
  portal_messages: Array<{
    id: string;
    sender: string;
    title: string;
    body: string;
    sent_at: string | null;
  }>;
  faqs: Array<{ id: number; question: string; answer: string; category: string }>;
  sections: {
    schedule: Array<{ id: number; title: string; event_date: string | null; start_time: string | null; location: string | null }>;
    accommodation: Array<{ id: number; name: string; city: string | null; country: string | null; website: string | null }>;
    transport: Array<{ id: number; name: string; pickup_location: string | null; dropoff_location: string | null; departure_time: string | null }>;
    registry: Array<{ id: number; name: string; store_url: string | null }>;
    gallery: Array<{ id: number; url: string; thumbnail_url: string | null; caption: string | null }>;
    guestbook: Array<{ guest_name: string | null; message: string; created_at: string }>;
  };
};

export default function WeddingPortalLanding({ slug }: { slug: string }) {
  const [data, setData] = useState<PortalData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE}/w/${slug}`)
      .then((response) => {
        if (!response.ok) throw new Error('This wedding portal is not available.');
        return response.json();
      })
      .then((payload: PortalData) => setData(payload))
      .catch((err) => setError(err instanceof Error ? err.message : 'This wedding portal is not available.'))
      .finally(() => setLoading(false));
  }, [slug]);

  const eventDateValue = data?.wedding.event_date ?? null;
  const [now, setNow] = useState<number>(() => Date.now());

  useEffect(() => {
    if (!eventDateValue) return;
    const interval = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(interval);
  }, [eventDateValue]);

  const countdown = useMemo(() => {
    if (!eventDateValue) return null;
    const event = new Date(`${eventDateValue}T00:00:00`);
    const diff = Math.max(0, event.getTime() - now);
    const days = Math.floor(diff / 86400000);
    const hours = Math.floor((diff % 86400000) / 3600000);
    const minutes = Math.floor((diff % 3600000) / 60000);
    const seconds = Math.floor((diff % 60000) / 1000);
    return { days, hours, minutes, seconds };
  }, [eventDateValue, now]);

  if (loading) {
    return <div className="min-h-screen bg-[#fbf7f4] flex items-center justify-center text-[#8c5367]">Loading wedding portal...</div>;
  }

  if (error || !data) {
    return (
      <div className="min-h-screen bg-[#fbf7f4] flex items-center justify-center p-6 text-center">
        <div>
          <Heart className="mx-auto mb-4 text-[#9b526d]" size={42} />
          <h1 className="font-serif text-3xl text-[#2d2729]">Portal unavailable</h1>
          <p className="mt-2 text-sm text-[#6f6768]">{error ?? 'This wedding portal is not available.'}</p>
        </div>
      </div>
    );
  }

  const { wedding, experience, sections } = data;
  const couple = wedding.couple_name_secondary ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}` : wedding.couple_name_primary;
  const location = [wedding.city, wedding.country].filter(Boolean).join(', ');
  const date = wedding.event_date
    ? new Date(`${wedding.event_date}T00:00:00`).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
    : 'Date to be announced';
  const heroImage = experience.cover_image_url || '/guest-portal/rose.jpeg';

  return (
    <main className="min-h-screen bg-[#fbf7f4] text-[#2d2729]">
      <section
        className="relative min-h-[520px] overflow-hidden bg-cover bg-center px-6 py-7 md:px-10"
        style={{ backgroundImage: `linear-gradient(90deg, rgba(255,255,255,.96) 0%, rgba(255,255,255,.88) 45%, rgba(255,255,255,.22) 100%), url(${heroImage})` }}
      >
        <header className="flex items-start justify-between">
          <div className="font-serif text-4xl leading-7 tracking-tight">udo<div className="font-sans text-[9px] uppercase tracking-[0.32em]">weddings</div></div>
        </header>

        <div className="mx-auto mt-12 max-w-3xl text-center md:mt-24">
          <div className="flex items-center justify-center gap-4 text-xs uppercase tracking-[0.38em] text-[#9b6a75] sm:gap-8">
            <span className="h-px w-8 bg-[#d9b9bd] sm:w-14" />
            Welcome to our wedding
            <span className="h-px w-8 bg-[#d9b9bd] sm:w-14" />
          </div>
          <Heart className="mx-auto mt-4 text-[#9b526d]" size={18} />
          <h1 className="mt-5 font-serif text-4xl sm:text-6xl md:text-7xl">{couple}</h1>
          <p className="mt-8 text-sm uppercase tracking-[0.36em] text-[#4f4648]">{date}{location ? `  -  ${location}` : ''}</p>
          <p className="mx-auto mt-9 max-w-md font-serif text-2xl text-[#6f4653]">{experience.welcome_message || "We're so happy you're here!"}</p>
          <p className="mt-2 text-sm text-[#5e5758]">Find everything you need to join us for our special day.</p>
        </div>
      </section>

      {!experience.published && (
        <section className="mx-auto mt-8 max-w-5xl rounded-xl border border-[#eadcda] bg-white p-6 text-center text-sm text-[#8c5367]">
          This wedding portal is being prepared. Some details may be hidden until it is published.
        </section>
      )}

      <section className="mx-auto -mt-16 grid max-w-7xl grid-cols-1 gap-6 px-6 xl:grid-cols-[1fr_320px]">
        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
          <PortalTile icon={<CalendarDays />} title="Wedding Schedule" text="View the full schedule of events and timings." cta="View Schedule" href="#schedule" primary />
          <PortalTile icon={<Map />} title="Venue & Map" text="Find the venue details and get directions." cta="View Map" href="#venue" />
          <PortalTile icon={<Bed />} title="Accommodation" text="Recommended hotels and booking information." cta="View Options" href="#accommodation" />
          <PortalTile icon={<Car />} title="Transportation" text="Shuttle services and transportation details." cta="View Routes" href="#transport" />
          <PortalTile icon={<Utensils />} title="Meal Selection" text="Let us know your meal preference through your invite link." cta="Add Your Choice" href="#rsvp" />
          <PortalTile icon={<Camera />} title="Photo Gallery" text="See all the moments from our journey." cta="View Gallery" href="#gallery" />
          <PortalTile icon={<Gift />} title="Gift Registry" text="Your presence is the best gift, but if you wish..." cta="View Registry" href="#registry" />
          <PortalTile icon={<HelpCircle />} title="FAQ" text="Find answers to common questions here." cta="View FAQ" href="#faq" />
        </div>
        <PortalRail alerts={data.portal_alerts} messages={data.portal_messages} />
      </section>

      <section className="mx-auto mt-6 grid max-w-7xl grid-cols-1 gap-6 px-6 lg:grid-cols-2">
        <Panel id="countdown" title="Wedding Countdown">
          <p className="text-sm text-[#6f6768]">The big day is almost here!</p>
          <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-4">
            {(['days', 'hours', 'minutes', 'seconds'] as const).map((key) => (
              <div key={key} className="rounded-lg border border-[#eadcda] bg-white/70 p-4 text-center">
                <div className="font-serif text-3xl">{countdown?.[key] ?? 0}</div>
                <div className="mt-1 text-xs uppercase tracking-wider text-[#6f6768]">{key}</div>
              </div>
            ))}
          </div>
        </Panel>
        <Panel id="contact" title="Contact Us" image="/guest-portal/rose.jpeg">
          <p className="max-w-sm text-sm leading-6 text-[#6f6768]">Need help or have a question? We are here for you.</p>
          <a href={`mailto:support@udoweddings.com?subject=${encodeURIComponent(`${couple} wedding question`)}`} className="mt-8 inline-flex items-center gap-2 rounded-lg border border-[#a76b80] px-8 py-3 text-sm font-semibold text-[#8c5367]">
            <MessageCircle size={17} />
            Message Us
          </a>
        </Panel>
      </section>

      <section id="rsvp" className="mx-auto mt-6 flex max-w-7xl flex-col gap-4 rounded-xl border border-[#eadcda] bg-white px-8 py-7 md:flex-row md:items-center md:justify-between">
        <div className="flex items-center gap-6">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-[#d7a7a3] to-[#9b526d] text-white"><Mail size={30} /></div>
          <div>
            <h2 className="font-serif text-2xl">Haven't RSVP'd yet?</h2>
            <p className="mt-1 text-sm text-[#6f6768]">Use the personalized invitation link sent to you so your RSVP, meal, and party details attach to your name.</p>
          </div>
        </div>
        <a href="#contact" className="rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-12 py-4 text-center text-sm font-semibold text-white">RSVP Now</a>
      </section>

      <section className="mx-auto mt-6 max-w-7xl overflow-hidden rounded-xl border border-[#eadcda] bg-white">
        <div className="grid min-h-[176px] grid-cols-1 md:grid-cols-[1fr_1.4fr]">
          <div className="flex items-center gap-8 p-8">
            <Heart className="text-[#c08c96]" size={30} />
            <div>
              <p className="font-serif text-2xl">"Two souls, one heart, a lifetime of love."</p>
              <p className="mt-5 text-sm text-[#6f6768]">Thank you for being a part of our story.</p>
            </div>
          </div>
          <img src="/guest-portal/beach.jpeg" alt="Wedding destination beach" className="h-full min-h-[176px] w-full object-cover" />
        </div>
      </section>

      <DetailsSections wedding={wedding} sections={sections} />

      <section className="mx-auto mt-6 max-w-7xl px-6">
        <Panel id="faq" title="Frequently Asked Questions">
          <FaqAccordion faqs={data.faqs} />
        </Panel>
      </section>

      <footer className="mx-auto mt-10 flex max-w-7xl flex-col gap-4 px-6 py-8 text-xs text-[#8a8081] md:flex-row md:items-center md:justify-between">
        <div className="font-serif text-3xl leading-6 text-[#2d2729]">udo<div className="font-sans text-[8px] uppercase tracking-[0.28em]">weddings</div></div>
        <div className="flex gap-8">
          <a href="/privacy" className="hover:text-[#8c5367]">Privacy Policy</a>
          <a href="/terms" className="hover:text-[#8c5367]">Terms of Use</a>
          <a href="#contact" className="hover:text-[#8c5367]">Contact Support</a>
        </div>
        <span>© {new Date().getFullYear()} {couple}</span>
      </footer>
    </main>
  );
}

function PortalTile({ icon, title, text, cta, href, primary = false }: { icon: ReactNode; title: string; text: string; cta: string; href: string; primary?: boolean }) {
  return (
    <article className="rounded-xl border border-[#eadcda] bg-white/95 p-9 text-center shadow-[0_16px_48px_rgba(80,53,45,.08)]">
      <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-[#f4ece9] text-[#9b526d] [&_svg]:h-9 [&_svg]:w-9">{icon}</div>
      <h2 className="mt-7 font-serif text-2xl">{title}</h2>
      <p className="mx-auto mt-4 max-w-[190px] text-sm leading-6 text-[#6f6768]">{text}</p>
      <a href={href} className={`mt-7 inline-flex w-full max-w-[180px] justify-center rounded-md border px-6 py-3 text-sm font-semibold ${primary ? 'border-[#8c5367] bg-[#8c5367] text-white' : 'border-[#b68190] text-[#8c5367]'}`}>{cta}</a>
    </article>
  );
}

function PortalRail({ alerts, messages }: { alerts: PortalData['portal_alerts']; messages: PortalData['portal_messages'] }) {
  return (
    <aside className="space-y-6">
      <section className="overflow-hidden rounded-xl border border-[#eadcda] bg-white/95 shadow-[0_16px_48px_rgba(80,53,45,.08)]">
        <div className="flex items-center gap-3 border-b border-[#f0e4e1] px-6 py-5">
          <Bell size={20} className="text-[#8c5367]" />
          <h2 className="font-serif text-2xl">Alerts</h2>
        </div>
        <div>
          {(alerts.length ? alerts.slice(0, 3) : [{ id: 'empty', type: 'alert', title: 'No active alerts', body: 'Updates will appear here when something needs attention.', target: null, trigger_at: null }]).map((alert, index) => (
            <a key={alert.id} href={alert.target === 'guests' ? '#rsvp' : alert.target === 'live' ? '#schedule' : '#contact'} className="flex gap-4 border-b border-[#f0e4e1] px-6 py-5 last:border-b-0">
              <div className="mt-1 text-[#9b526d]">{alertIcon(alert.type)}</div>
              <div className="min-w-0 flex-1">
                <p className="text-sm font-semibold text-[#2d2729]">{alert.title}</p>
                {alert.body && <p className="mt-1 text-xs leading-5 text-[#6f6768]">{alert.body}</p>}
              </div>
              {index < alerts.length && <span className="text-[#8c5367]">›</span>}
            </a>
          ))}
        </div>
        <a href="#contact" className="flex items-center justify-between border-t border-[#f0e4e1] px-6 py-4 text-sm text-[#8c5367]">
          View All Alerts
          <span>›</span>
        </a>
      </section>

      <section className="overflow-hidden rounded-xl border border-[#eadcda] bg-white/95 shadow-[0_16px_48px_rgba(80,53,45,.08)]">
        <div className="flex items-center justify-between border-b border-[#f0e4e1] px-6 py-5">
          <div className="flex items-center gap-3">
            <Mail size={20} className="text-[#8c5367]" />
            <h2 className="font-serif text-2xl">Messages</h2>
          </div>
          <a href="#contact" className="text-sm text-[#8c5367]">View All</a>
        </div>
        <div>
          {(messages.length ? messages.slice(0, 3) : [{ id: 'empty', sender: 'Wedding Team', title: 'No messages yet', body: 'Messages and updates will appear here once they are sent.', sent_at: null }]).map((message) => (
            <div key={message.id} className="flex gap-4 border-b border-[#f0e4e1] px-6 py-5 last:border-b-0">
              <div className="flex h-11 w-11 flex-none items-center justify-center rounded-full bg-[#f4ece9] text-[#9b526d]">
                {message.sender === 'Gift Registry' ? <Gift size={20} /> : <Heart size={20} />}
              </div>
              <div className="min-w-0 flex-1">
                <div className="flex items-start justify-between gap-3">
                  <p className="text-sm font-semibold text-[#2d2729]">{message.sender}</p>
                  <span className="whitespace-nowrap text-xs text-[#8a8081]">{shortDate(message.sent_at)}</span>
                </div>
                <p className="mt-1 text-xs leading-5 text-[#6f6768]">{message.body || message.title}</p>
              </div>
            </div>
          ))}
        </div>
      </section>
    </aside>
  );
}

function alertIcon(type: string) {
  if (type === 'logistics') return <Plane size={20} />;
  if (type === 'rsvp') return <CalendarDays size={20} />;
  if (type === 'incident') return <Bell size={20} />;
  return <ClockIcon />;
}

function ClockIcon() {
  return <CalendarDays size={20} />;
}

function shortDate(value: string | null) {
  if (!value) return '';
  return new Date(value).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

function Panel({ id, title, children, image }: { id: string; title: string; children: ReactNode; image?: string }) {
  return (
    <section id={id} className="relative overflow-hidden rounded-xl border border-[#eadcda] bg-white p-10">
      {image && <img src={image} alt="" className="absolute bottom-0 right-0 h-44 w-44 translate-x-8 translate-y-8 rounded-full object-cover opacity-20" />}
      <h2 className="font-serif text-2xl">{title}</h2>
      <div className="mt-1 flex items-center gap-3 text-[#9b526d]"><span className="h-px w-12 bg-[#d9b9bd]" /><Heart size={14} /><span className="h-px w-12 bg-[#d9b9bd]" /></div>
      <div className="relative mt-4">{children}</div>
    </section>
  );
}

function DetailsSections({ wedding, sections }: { wedding: Wedding; sections: PortalData['sections'] }) {
  const venueLine = [wedding.venue, wedding.venue_address, wedding.city, wedding.country].filter(Boolean).join(' - ');
  return (
    <section className="mx-auto mt-6 grid max-w-7xl grid-cols-1 gap-6 px-6 lg:grid-cols-2">
      <Panel id="schedule" title="Schedule">
        <Rows rows={sections.schedule.map((item) => `${item.title}${item.start_time ? ` - ${item.start_time}` : ''}${item.location ? `, ${item.location}` : ''}`)} empty="Schedule details will appear here soon." />
      </Panel>
      <Panel id="venue" title="Venue & Map">
        <Rows rows={[venueLine].filter(Boolean)} empty="Venue details will appear here soon." />
      </Panel>
      <Panel id="accommodation" title="Accommodation">
        <Rows rows={sections.accommodation.map((item) => [item.name, item.city, item.country].filter(Boolean).join(' - '))} empty="Accommodation options will appear here soon." />
      </Panel>
      <Panel id="transport" title="Transportation">
        <Rows rows={sections.transport.map((item) => [item.name, item.pickup_location, item.dropoff_location].filter(Boolean).join(' - '))} empty="Transportation details will appear here soon." />
      </Panel>
      <Panel id="registry" title="Gift Registry">
        <Rows rows={sections.registry.map((item) => item.name)} empty="Registry details will appear here soon." />
      </Panel>
      <Panel id="gallery" title="Photo Gallery">
        {sections.gallery.length > 0 ? (
          <div className="grid grid-cols-3 gap-3">{sections.gallery.slice(0, 6).map((item) => <img key={item.id} src={item.thumbnail_url ?? item.url} alt={item.caption ?? 'Wedding gallery'} className="aspect-square rounded-lg object-cover" />)}</div>
        ) : <p className="text-sm text-[#6f6768]">Gallery moments will appear here soon.</p>}
      </Panel>
    </section>
  );
}

function Rows({ rows, empty }: { rows: string[]; empty: string }) {
  const cleanRows = rows.filter(Boolean);
  if (cleanRows.length === 0) return <p className="text-sm text-[#6f6768]">{empty}</p>;
  return <div className="space-y-3">{cleanRows.slice(0, 5).map((row, index) => <div key={index} className="rounded-lg border border-[#f0e4e1] bg-[#fffaf8] p-3 text-sm text-[#4f4648]">{row}</div>)}</div>;
}

function FaqAccordion({ faqs }: { faqs: PortalData['faqs'] }) {
  const [openId, setOpenId] = useState<number | null>(null);

  if (faqs.length === 0) {
    return <p className="text-sm text-[#6f6768]">Answers to common questions will appear here soon.</p>;
  }

  return (
    <div className="space-y-3">
      {faqs.map((faq) => {
        const open = openId === faq.id;
        return (
          <div key={faq.id} className="overflow-hidden rounded-lg border border-[#f0e4e1] bg-[#fffaf8]">
            <button
              type="button"
              onClick={() => setOpenId(open ? null : faq.id)}
              className="flex w-full items-center justify-between gap-4 p-4 text-left text-sm font-medium text-[#4f4648]"
              aria-expanded={open}
            >
              {faq.question}
              <ChevronDown size={16} className={`flex-shrink-0 text-[#9b526d] transition-transform ${open ? 'rotate-180' : ''}`} />
            </button>
            {open && <p className="px-4 pb-4 text-sm leading-6 text-[#6f6768]">{faq.answer}</p>}
          </div>
        );
      })}
    </div>
  );
}
