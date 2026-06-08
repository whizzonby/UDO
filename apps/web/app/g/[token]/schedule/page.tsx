import { notFound } from 'next/navigation';
import { MapPin, Clock } from 'lucide-react';
import { guestApi } from '@/lib/api';
import { formatDate, formatTime } from '@/lib/utils';

export default async function SchedulePage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  let data;
  try {
    data = await guestApi.getSchedule(token);
  } catch {
    notFound();
  }

  const grouped = data.events.reduce<Record<string, typeof data.events>>((acc, event) => {
    const key = event.event_date ?? 'TBD';
    if (!acc[key]) acc[key] = [];
    acc[key]!.push(event);
    return acc;
  }, {});

  return (
    <div className="min-h-screen bg-[--color-udo-cream] px-4 py-8">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <Clock size={24} className="text-[--color-udo-pink]" />
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700]">Schedule</h1>
        {data.wedding_date && (
          <p className="text-sm text-[--color-udo-grey-500] mt-1">
            {formatDate(data.wedding_date)}
          </p>
        )}
      </div>

      {data.events.length === 0 ? (
        <div className="text-center py-16">
          <p className="text-[--color-udo-grey-400] text-sm">Schedule coming soon</p>
        </div>
      ) : (
        <div className="space-y-8 max-w-md mx-auto">
          {Object.entries(grouped).map(([date, events]) => (
            <div key={date}>
              <div className="flex items-center gap-3 mb-4">
                <div className="h-px flex-1 bg-[--color-udo-grey-200]" />
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">
                  {date !== 'TBD' ? formatDate(date, 'EEEE, MMMM d') : 'Date TBD'}
                </p>
                <div className="h-px flex-1 bg-[--color-udo-grey-200]" />
              </div>

              <div className="relative">
                {/* Timeline spine */}
                <div className="absolute left-[52px] top-0 bottom-0 w-px bg-[--color-udo-grey-200]" />

                <div className="space-y-4">
                  {events.map((event, i) => (
                    <div key={event.id} className="flex items-start gap-4">
                      {/* Time column */}
                      <div className="w-[52px] shrink-0 text-right pt-3">
                        {event.start_time ? (
                          <span className="text-xs font-semibold text-[--color-udo-grey-400] leading-none">
                            {formatTime(event.start_time)}
                          </span>
                        ) : null}
                      </div>

                      {/* Dot */}
                      <div className="relative z-10 mt-3 w-3 h-3 rounded-full border-2 border-[--color-udo-pink] bg-white shrink-0 -ml-1.5" />

                      {/* Content */}
                      <div className="flex-1 bg-white rounded-2xl p-4 border border-[--color-udo-grey-200] mb-1">
                        <p className="font-semibold text-sm text-[--color-udo-grey-700]">{event.title}</p>
                        {event.description && (
                          <p className="text-xs text-[--color-udo-grey-500] mt-1 leading-relaxed">
                            {event.description}
                          </p>
                        )}
                        {(event.location || event.end_time) && (
                          <div className="flex flex-wrap items-center gap-3 mt-2">
                            {event.location && (
                              <span className="flex items-center gap-1 text-xs text-[--color-udo-grey-400]">
                                <MapPin size={10} />
                                {event.location}
                              </span>
                            )}
                            {event.end_time && (
                              <span className="text-xs text-[--color-udo-grey-400]">
                                until {formatTime(event.end_time)}
                              </span>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
