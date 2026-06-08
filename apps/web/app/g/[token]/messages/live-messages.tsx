'use client';

// Requires these env vars (prefixed NEXT_PUBLIC_ so they're available in the browser):
//   NEXT_PUBLIC_REVERB_HOST       (default: localhost)
//   NEXT_PUBLIC_REVERB_PORT       (default: 8080)
//   NEXT_PUBLIC_REVERB_APP_KEY    (default: udo-key)
//   NEXT_PUBLIC_REVERB_SCHEME     (default: http)

import { useEffect, useRef, useState } from 'react';
import Pusher from 'pusher-js';
import { MessageCircle } from 'lucide-react';
import { formatDate } from '@/lib/utils';
import type { Message } from '@/lib/api';

interface Props {
  weddingId: string;
  initialMessages: Message[];
}

export default function LiveMessages({ weddingId, initialMessages }: Props) {
  const [messages, setMessages] = useState<Message[]>(initialMessages);
  const seenIds = useRef(new Set(initialMessages.map((m) => m.id)));

  useEffect(() => {
    const host   = process.env.NEXT_PUBLIC_REVERB_HOST    ?? 'localhost';
    const port   = parseInt(process.env.NEXT_PUBLIC_REVERB_PORT   ?? '8080', 10);
    const key    = process.env.NEXT_PUBLIC_REVERB_APP_KEY ?? 'udo-key';
    const scheme = process.env.NEXT_PUBLIC_REVERB_SCHEME  ?? 'http';
    const tls    = scheme === 'https';

    const pusher = new Pusher(key, {
      wsHost: host,
      wsPort: port,
      wssPort: port,
      forceTLS: tls,
      enabledTransports: ['ws', 'wss'],
      disableStats: true,
      cluster: '',
    });

    const ch = pusher.subscribe(`wedding.${weddingId}`);

    ch.bind('announcement.sent', (data: Message) => {
      if (!seenIds.current.has(data.id)) {
        seenIds.current.add(data.id);
        setMessages((prev) => [data, ...prev]);
      }
    });

    return () => {
      ch.unbind_all();
      pusher.unsubscribe(`wedding.${weddingId}`);
      pusher.disconnect();
    };
  }, [weddingId]);

  if (messages.length === 0) {
    return (
      <div className="text-center py-16">
        <MessageCircle size={48} className="text-[--color-udo-grey-300] mx-auto mb-4" />
        <p className="text-[--color-udo-grey-500] text-sm">No messages yet</p>
        <p className="text-[--color-udo-grey-400] text-xs mt-1">
          Any updates from the couple will appear here
        </p>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto space-y-4">
      {messages.map((msg) => (
        <div
          key={msg.id}
          className="bg-white rounded-2xl p-5 border border-[--color-udo-grey-200]"
        >
          <div className="flex items-center gap-2 mb-3">
            <div className="w-7 h-7 rounded-full bg-[--color-udo-pink]/15 flex items-center justify-center">
              <MessageCircle size={13} className="text-[--color-udo-pink]" />
            </div>
            {msg.subject && (
              <p className="font-semibold text-sm text-[--color-udo-grey-700] leading-none">
                {msg.subject}
              </p>
            )}
            {msg.sent_at && (
              <span className="ml-auto text-xs text-[--color-udo-grey-400]">
                {formatDate(msg.sent_at, 'MMM d')}
              </span>
            )}
          </div>
          <p className="text-sm text-[--color-udo-grey-600] leading-relaxed whitespace-pre-line">
            {msg.body}
          </p>
        </div>
      ))}
    </div>
  );
}
