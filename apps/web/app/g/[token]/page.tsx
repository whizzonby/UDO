import { notFound } from 'next/navigation';
import Link from 'next/link';
import { Calendar, MapPin, Heart, ChevronRight, Clock, Gift } from 'lucide-react';
import { guestApi } from '@/lib/api';
import { formatDate, daysUntil, coupleNames } from '@/lib/utils';

export default async function GuestHomePage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  let data;
  try {
    data = await guestApi.getPortal(token);
  } catch {
    notFound();
  }

  const { guest, wedding, experience, day_schedule } = data;
  const days = daysUntil(wedding.wedding_date);
  const names = coupleNames(wedding.partner_one_name, wedding.partner_two_name);
  const hasResponded = guest.rsvp_status !== 'pending';

  return (
    <div className="min-h-screen bg-[--color-udo-cream]">
      {/* Hero */}
      <div
        className="relative flex flex-col items-center justify-end px-6 pt-16 pb-10 text-center min-h-[55vh]"
        style={{
          background: wedding.cover_photo_url
            ? undefined
            : 'linear-gradient(160deg, #FF4D8C 0%, #D4006A 100%)',
          backgroundImage: wedding.cover_photo_url
            ? `linear-gradient(to bottom, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.55) 100%), url(${wedding.cover_photo_url})`
            : undefined,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        {/* Live badge */}
        {wedding.is_live && (
          <div className="absolute top-6 left-1/2 -translate-x-1/2 flex items-center gap-1.5 bg-white/20 backdrop-blur-sm rounded-full px-3 py-1">
            <span className="w-2 h-2 rounded-full bg-red-400 animate-pulse" />
            <span className="text-white text-xs font-semibold tracking-wide">LIVE NOW</span>
          </div>
        )}

        <div className="text-white">
          <p className="text-sm font-medium tracking-widest uppercase opacity-80 mb-3">
            You&apos;re invited
          </p>
          <h1 className="font-display text-4xl font-bold leading-tight mb-2">
            {names}
          </h1>
          {wedding.wedding_date && (
            <p className="text-white/90 font-medium">
              {formatDate(wedding.wedding_date, 'EEEE, MMMM d, yyyy')}
            </p>
          )}
          {days !== null && days >= 0 && (
            <p className="mt-2 text-white/75 text-sm">
              {days === 0 ? 'Today! 🎉' : `${days} day${days === 1 ? '' : 's'} to go`}
            </p>
          )}
          {days !== null && days < 0 && (
            <p className="mt-2 text-white/75 text-sm">What a beautiful day it was 💫</p>
          )}
        </div>
      </div>

      {/* Welcome message */}
      {experience?.welcome_message && (
        <div className="mx-4 -mt-6 relative z-10 bg-white rounded-2xl p-5 shadow-sm border border-[--color-udo-grey-200]">
          <p className="text-sm text-[--color-udo-grey-700] leading-relaxed italic text-center">
            &ldquo;{experience.welcome_message}&rdquo;
          </p>
        </div>
      )}

      <div className="px-4 py-6 space-y-4">
        {/* Personal greeting */}
        <div className="bg-[--color-udo-blush] rounded-2xl p-5 flex items-start gap-4">
          <div className="w-10 h-10 rounded-full bg-[--color-udo-pink] flex items-center justify-center shrink-0">
            <span className="text-white font-bold text-sm">
              {guest.first_name[0]?.toUpperCase()}
            </span>
          </div>
          <div>
            <p className="font-semibold text-[--color-udo-grey-700]">
              Hi, {guest.first_name}! 👋
            </p>
            <p className="text-sm text-[--color-udo-grey-500] mt-0.5">
              {hasResponded
                ? guest.rsvp_status === 'attending'
                  ? "We can't wait to celebrate with you!"
                  : guest.rsvp_status === 'declined'
                  ? "Sorry you can't make it — you'll be missed."
                  : "Thanks for letting us know!"
                : "We'd love to know if you can join us."}
            </p>
          </div>
        </div>

        {/* RSVP card */}
        {!hasResponded && (
          <Link
            href={`/g/${token}/rsvp`}
            className="block bg-white rounded-2xl p-5 border border-[--color-udo-grey-200] hover:border-[--color-udo-pink] transition-colors group"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-[--color-udo-pink]/10 flex items-center justify-center">
                  <Heart size={18} className="text-[--color-udo-pink]" />
                </div>
                <div>
                  <p className="font-semibold text-sm text-[--color-udo-grey-700]">RSVP now</p>
                  <p className="text-xs text-[--color-udo-grey-500]">Let us know you&apos;re coming</p>
                </div>
              </div>
              <ChevronRight size={18} className="text-[--color-udo-grey-400] group-hover:text-[--color-udo-pink] transition-colors" />
            </div>
          </Link>
        )}

        {/* RSVP confirmed banner */}
        {guest.rsvp_status === 'attending' && (
          <div className="bg-[--color-udo-teal]/10 border border-[--color-udo-teal]/25 rounded-2xl p-4 flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[--color-udo-teal]/20 flex items-center justify-center">
              <Heart size={16} className="text-[--color-udo-teal] fill-[--color-udo-teal]" />
            </div>
            <div>
              <p className="text-sm font-semibold text-[--color-udo-teal]">You&apos;re attending! 🎉</p>
              <Link href={`/g/${token}/rsvp`} className="text-xs text-[--color-udo-teal]/70 underline">
                Update your RSVP
              </Link>
            </div>
          </div>
        )}

        {/* Venue card */}
        {(experience?.show_venue !== false) && wedding.venue_name && (
          <div className="bg-white rounded-2xl p-5 border border-[--color-udo-grey-200]">
            <div className="flex items-center gap-2 mb-3">
              <MapPin size={16} className="text-[--color-udo-pink]" />
              <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">Venue</p>
            </div>
            <p className="font-semibold text-[--color-udo-grey-700]">{wedding.venue_name}</p>
            {wedding.venue_address && (
              <p className="text-sm text-[--color-udo-grey-500] mt-1">{wedding.venue_address}</p>
            )}
            {wedding.venue_city && (
              <p className="text-sm text-[--color-udo-grey-500]">{wedding.venue_city}</p>
            )}
          </div>
        )}

        {/* Day schedule preview */}
        {(experience?.show_schedule !== false) && day_schedule.length > 0 && (
          <div className="bg-white rounded-2xl p-5 border border-[--color-udo-grey-200]">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Clock size={16} className="text-[--color-udo-pink]" />
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">Day schedule</p>
              </div>
              <Link href={`/g/${token}/schedule`} className="text-xs text-[--color-udo-pink] font-medium">
                See all
              </Link>
            </div>
            <div className="space-y-3">
              {day_schedule.slice(0, 3).map((event) => (
                <div key={event.id} className="flex items-start gap-3">
                  <div className="text-right shrink-0 w-14">
                    {event.start_time && (
                      <span className="text-xs text-[--color-udo-grey-400] font-medium">
                        {formatTime(event.start_time)}
                      </span>
                    )}
                  </div>
                  <div className="w-px self-stretch bg-[--color-udo-grey-200] relative">
                    <div className="absolute top-1 -left-[3px] w-1.5 h-1.5 rounded-full bg-[--color-udo-pink]" />
                  </div>
                  <div className="pb-2">
                    <p className="text-sm font-medium text-[--color-udo-grey-700]">{event.title}</p>
                    {event.location && (
                      <p className="text-xs text-[--color-udo-grey-400] mt-0.5">{event.location}</p>
                    )}
                  </div>
                </div>
              ))}
              {day_schedule.length > 3 && (
                <Link href={`/g/${token}/schedule`} className="block text-xs text-center text-[--color-udo-pink] font-medium pt-1">
                  +{day_schedule.length - 3} more events →
                </Link>
              )}
            </div>
          </div>
        )}

        {/* Quick links */}
        <div className="grid grid-cols-2 gap-3">
          {(experience?.show_registry !== false) && (
            <Link href={`/g/${token}/registry`} className="bg-white rounded-2xl p-4 border border-[--color-udo-grey-200] flex flex-col gap-2 hover:border-[--color-udo-pink] transition-colors group">
              <Gift size={22} className="text-[--color-udo-pink]" />
              <p className="text-sm font-semibold text-[--color-udo-grey-700]">Registry</p>
              <p className="text-xs text-[--color-udo-grey-400]">Gifts & fund</p>
            </Link>
          )}
          {(experience?.show_gallery !== false) && (
            <Link href={`/g/${token}/gallery`} className="bg-white rounded-2xl p-4 border border-[--color-udo-grey-200] flex flex-col gap-2 hover:border-[--color-udo-pink] transition-colors group">
              <Calendar size={22} className="text-[--color-udo-pink]" />
              <p className="text-sm font-semibold text-[--color-udo-grey-700]">Gallery</p>
              <p className="text-xs text-[--color-udo-grey-400]">Photos & memories</p>
            </Link>
          )}
        </div>

        {/* Date card */}
        {wedding.wedding_date && (
          <div className="text-center py-4">
            <p className="font-display text-lg text-[--color-udo-grey-400]">
              {formatDate(wedding.wedding_date)}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

function formatTime(timeStr: string): string {
  try {
    const [h, m] = timeStr.split(':').map(Number);
    const d = new Date();
    d.setHours(h!, m!, 0);
    return d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
  } catch {
    return timeStr;
  }
}
