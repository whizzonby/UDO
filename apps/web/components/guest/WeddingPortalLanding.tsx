'use client';

/* eslint-disable @next/next/no-img-element */

import { useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';
import {
  Bed,
  Bell,
  CalendarDays,
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
const SUPPORT_EMAIL = 'hello@udowedding.com';

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
  dress_code: string | null;
  dress_code_details: string | null;
  cover_image_url: string | null;
  theme_color: string;
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
    meal_selection: boolean;
    rsvp: boolean;
    plus_one: boolean;
    messages: boolean;
  };
};

type PortalData = {
  portal_url: string;
  gallery_upload_url: string | null;
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
    transport: Array<{ id: number; name: string; pickup_location: string | null; dropoff_location: string | null; departure_time: string | null; driver_name?: string | null; driver_phone?: string | null; notes?: string | null; passengers?: string[] }>;
    seating: { table_name: string; seat_number: number | null; seat_label: string | null; notes: string | null } | null;
    registry: Array<{ id: number; type: string; name: string; description: string | null; image_url: string | null; store_name: string | null; store_url: string | null; price: number | null; currency: string | null; fund_goal: number | null; fund_raised: number | null; is_priority: boolean }>;
    gallery: Array<{ id: number; url: string; thumbnail_url: string | null; caption: string | null }>;
    live_updates: Array<{ id: number; title: string; body: string | null; event_time: string | null }>;
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
  const portalTiles = [
    experience.sections.schedule && <PortalTile key="schedule" icon={<CalendarDays />} title="Wedding Schedule" text="View the full schedule of events and timings." cta="View Schedule" href="#schedule" primary />,
    experience.sections.venue_map && <PortalTile key="venue" icon={<Map />} title="Venue & Map" text="Find the venue details and get directions." cta="View Map" href="#venue" />,
    experience.sections.accommodation && <PortalTile key="accommodation" icon={<Bed />} title="Accommodation" text="Recommended hotels and booking information." cta="View Options" href="#accommodation" />,
    experience.sections.rsvp && experience.sections.meal_selection && <PortalTile key="meal" icon={<Utensils />} title="Meal Selection" text="Let us know your meal preference through your invite link." cta="Add Your Choice" href="#rsvp" />,
    experience.sections.registry && <PortalTile key="registry" icon={<Gift />} title="Gift Registry" text="Your presence is the best gift, but if you wish..." cta="View Registry" href="#registry" />,
    data.faqs.length > 0 && <PortalTile key="faq" icon={<HelpCircle />} title="FAQ" text="Find answers to common questions here." cta="View FAQ" href="#faq" />,
  ].filter(Boolean);
  const showRail = experience.sections.live_feed || experience.sections.messages || data.portal_alerts.length > 0 || data.portal_messages.length > 0;

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

      <section className={`mx-auto mt-6 grid max-w-7xl grid-cols-1 gap-6 px-6 md:-mt-16 ${showRail ? 'xl:grid-cols-[1fr_320px]' : ''}`}>
        {portalTiles.length > 0 && (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-4">
            {portalTiles}
          </div>
        )}
        {showRail && <PortalRail alerts={data.portal_alerts} messages={data.portal_messages} />}
      </section>

      <section className="mx-auto mt-6 grid max-w-7xl grid-cols-1 gap-6 px-6 lg:grid-cols-2">
        <Panel id="countdown" title="Wedding Countdown">
          <p className="text-sm text-[#6f6768]">The big day is almost here!</p>
          <div className="mt-6 grid grid-cols-2 gap-3 min-[430px]:grid-cols-4 sm:gap-4">
            {(['days', 'hours', 'minutes', 'seconds'] as const).map((key) => (
              <div key={key} className="min-w-0 rounded-lg border border-[#eadcda] bg-white/70 px-2 py-4 text-center sm:p-4">
                <div className="font-serif text-3xl leading-none">{countdown?.[key] ?? 0}</div>
                <div className="mt-2 text-[10px] uppercase tracking-[0.12em] text-[#6f6768] sm:text-xs sm:tracking-wider">{key}</div>
              </div>
            ))}
          </div>
        </Panel>
        <Panel id="contact" title="Contact Us" image="/guest-portal/rose.jpeg">
          <p className="max-w-sm text-sm leading-6 text-[#6f6768]">Need help or have a question? We are here for you.</p>
          <a href={`mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(`${couple} wedding question`)}`} className="mt-8 inline-flex items-center gap-2 rounded-lg border border-[#a76b80] px-8 py-3 text-sm font-semibold text-[#8c5367]">
            <MessageCircle size={17} />
            Message Us
          </a>
          {/* Some mobile browsers/webviews have no mail app registered and
              silently do nothing when a mailto: link is tapped — show the
              address as plain text too so there's always a working fallback. */}
          <p className="mt-3 text-xs text-[#6f6768]">Button not opening your email app? Reach us directly at <span className="font-medium text-[#8c5367]">{SUPPORT_EMAIL}</span>.</p>
        </Panel>
      </section>

      {experience.sections.rsvp && (
        <section id="rsvp" className="mx-auto mt-6 flex max-w-7xl flex-col gap-4 rounded-xl border border-[#eadcda] bg-white px-8 py-7 md:flex-row md:items-center md:justify-between">
          <div className="flex items-center gap-6">
            <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gradient-to-br from-[#d7a7a3] to-[#9b526d] text-white"><Mail size={30} /></div>
            <div>
              <h2 className="font-serif text-2xl">Haven't RSVP'd yet?</h2>
              <p className="mt-1 text-sm text-[#6f6768]">Use the personalized invitation link sent to you so your RSVP, meal, and party details attach to your name. Can't find it? Message us below and we'll resend it.</p>
            </div>
          </div>
          <a href={`mailto:${SUPPORT_EMAIL}?subject=${encodeURIComponent(`RSVP help - ${couple} wedding`)}`} className="rounded-lg bg-gradient-to-r from-[#8c5367] to-[#a76b80] px-12 py-4 text-center text-sm font-semibold text-white">Request My Invite Link</a>
        </section>
      )}

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

      <DetailsSections wedding={wedding} experience={experience} sections={sections} galleryUploadUrl={data.gallery_upload_url} />

      {data.faqs.length > 0 && (
        <section className="mx-auto mt-6 max-w-7xl px-6">
          <Panel id="faq" title="Frequently Asked Questions">
            <FaqAccordion faqs={data.faqs} />
          </Panel>
        </section>
      )}

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

function DetailsSections({ wedding, experience, sections, galleryUploadUrl }: { wedding: Wedding; experience: Experience; sections: PortalData['sections']; galleryUploadUrl: string | null }) {
  const venueLine = [wedding.venue, wedding.venue_address, wedding.city, wedding.country].filter(Boolean).join(' - ');
  const visiblePanels = [
    experience.sections.schedule && (
      <Panel key="schedule" id="schedule" title="Schedule">
        <Rows rows={sections.schedule.map((item) => `${item.title}${item.start_time ? ` - ${item.start_time}` : ''}${item.location ? `, ${item.location}` : ''}`)} empty="Schedule details will appear here soon." />
      </Panel>
    ),
    experience.sections.venue_map && (
      <Panel key="venue" id="venue" title="Venue & Map">
        <Rows rows={[venueLine].filter(Boolean)} empty="Venue details will appear here soon." />
      </Panel>
    ),
    experience.sections.dress_code && (
      <Panel key="dress" id="dress-code" title="Dress Code">
        <Rows rows={[experience.dress_code, experience.dress_code_details].filter(Boolean) as string[]} empty="Dress code details will appear here soon." />
      </Panel>
    ),
    experience.sections.accommodation && (
      <Panel key="accommodation" id="accommodation" title="Accommodation">
        <Rows rows={sections.accommodation.map((item) => [item.name, item.city, item.country].filter(Boolean).join(' - '))} empty="Accommodation options will appear here soon." />
      </Panel>
    ),
    experience.sections.transport && (
      <Panel key="transport" id="transport" title="Transportation">
        <TransportRoutes routes={sections.transport} />
      </Panel>
    ),
    experience.sections.seating && sections.seating && (
      <Panel key="seating" id="seating" title="Seating">
        <Rows rows={[[sections.seating.table_name, sections.seating.seat_label || sections.seating.seat_number, sections.seating.notes].filter(Boolean).join(' - ')]} empty="Seating details will appear here soon." />
      </Panel>
    ),
    experience.sections.live_feed && (
      <Panel key="live" id="live" title="Live Updates">
        <Rows rows={sections.live_updates.map((item) => `${item.title}${item.body ? ` - ${item.body}` : ''}`)} empty="Live updates will appear here soon." />
      </Panel>
    ),
    experience.sections.registry && (
      <Panel key="registry" id="registry" title="Gift Registry">
        <RegistryItems items={sections.registry} />
      </Panel>
    ),
    experience.sections.gallery && (
      <Panel key="gallery" id="gallery" title="Photo Gallery">
        <PhotoGalleryPanel items={sections.gallery} uploadUrl={galleryUploadUrl} />
      </Panel>
    ),
    experience.sections.messages && (
      <Panel key="guestbook" id="guestbook" title="Guestbook">
        <Rows rows={sections.guestbook.map((item) => `${item.guest_name || 'Guest'}: ${item.message}`)} empty="Guestbook messages will appear here soon." />
      </Panel>
    ),
  ].filter(Boolean);

  if (visiblePanels.length === 0) return null;

  return (
    <section className="mx-auto mt-6 grid max-w-7xl grid-cols-1 gap-6 px-6 lg:grid-cols-2">
      {visiblePanels}
    </section>
  );
}

function PhotoGalleryPanel({ items, uploadUrl }: { items: PortalData['sections']['gallery']; uploadUrl: string | null }) {
  return (
    <div>
      {items.length > 0 ? (
        <div className="grid grid-cols-3 gap-3">{items.slice(0, 6).map((item) => <img key={item.id} src={item.thumbnail_url ?? item.url} alt={item.caption ?? 'Wedding gallery'} className="aspect-square rounded-lg object-cover" />)}</div>
      ) : (
        <p className="text-sm text-[#6f6768]">Gallery moments will appear here soon.</p>
      )}
      {uploadUrl && (
        <a href={uploadUrl} className="mt-5 inline-flex w-full justify-center rounded-md bg-[#8c5367] px-6 py-3 text-sm font-semibold text-white">
          Upload photos, videos or voice notes
        </a>
      )}
    </div>
  );
}

function TransportRoutes({ routes }: { routes: PortalData['sections']['transport'] }) {
  const [openId, setOpenId] = useState<number | null>(routes[0]?.id ?? null);
  if (routes.length === 0) return <p className="text-sm text-[#6f6768]">Transportation details will appear here soon.</p>;

  return (
    <div className="space-y-3">
      {routes.map((route) => {
        const open = openId === route.id;
        const passengers = route.passengers ?? [];
        return (
          <div key={route.id} className="overflow-hidden rounded-lg border border-[#f0e4e1] bg-[#fffaf8]">
            <button
              type="button"
              onClick={() => setOpenId(open ? null : route.id)}
              className="flex w-full items-center justify-between gap-4 p-4 text-left"
              aria-expanded={open}
            >
              <div>
                <p className="text-sm font-semibold text-[#4f4648]">{route.name}</p>
                <p className="mt-1 text-xs text-[#6f6768]">{[route.pickup_location, route.dropoff_location].filter(Boolean).join(' to ') || 'Route details'}</p>
              </div>
              <ChevronDown size={16} className={`flex-shrink-0 text-[#9b526d] transition-transform ${open ? 'rotate-180' : ''}`} />
            </button>
            {open && (
              <div className="border-t border-[#f0e4e1] px-4 pb-4 pt-3 text-sm text-[#4f4648]">
                <Rows rows={[
                  route.departure_time ? `Departure: ${new Date(route.departure_time).toLocaleString()}` : '',
                  route.driver_name || route.driver_phone ? `Driver: ${[route.driver_name, route.driver_phone].filter(Boolean).join(' - ')}` : '',
                  route.notes || '',
                ]} empty="More route details will appear here soon." />
                <div className="mt-4">
                  <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#9b526d]">Guests on this transport</p>
                  {passengers.length > 0 ? (
                    <div className="mt-2 flex flex-wrap gap-2">
                      {passengers.map((name) => <span key={name} className="rounded-full border border-[#eadcda] bg-white px-3 py-1 text-xs text-[#4f4648]">{name}</span>)}
                    </div>
                  ) : (
                    <p className="mt-2 text-xs text-[#6f6768]">Guest assignments will appear here once confirmed.</p>
                  )}
                </div>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

function RegistryItems({ items }: { items: PortalData['sections']['registry'] }) {
  if (items.length === 0) return <p className="text-sm text-[#6f6768]">Registry details will appear here soon.</p>;

  return (
    <div className="space-y-3">
      {items.map((item) => {
        const amount = item.price ?? item.fund_goal;
        const amountLabel = amount ? `${item.currency ?? 'USD'} ${amount}` : null;
        const cta = item.store_url ? (item.type === 'cash_fund' ? 'Contribute' : 'View gift') : 'Use invitation link';
        const body = (
          <>
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-sm font-semibold text-[#4f4648]">{item.name}</p>
                {item.description && <p className="mt-1 text-xs leading-5 text-[#6f6768]">{item.description}</p>}
                {amountLabel && <p className="mt-2 text-xs font-semibold text-[#9b526d]">{amountLabel}</p>}
              </div>
              <span className="rounded-full border border-[#eadcda] px-3 py-1 text-xs text-[#8c5367]">{cta}</span>
            </div>
            {!item.store_url && (
              <p className="mt-3 text-xs leading-5 text-[#6f6768]">Cash pledges and personalized contributions are handled through each guest's invitation link.</p>
            )}
          </>
        );
        return item.store_url ? (
          <a key={item.id} href={item.store_url} target="_blank" rel="noreferrer" className="block rounded-lg border border-[#f0e4e1] bg-[#fffaf8] p-4 transition hover:border-[#b68190]">
            {body}
          </a>
        ) : (
          <div key={item.id} className="rounded-lg border border-[#f0e4e1] bg-[#fffaf8] p-4">
            {body}
          </div>
        );
      })}
    </div>
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
