import { notFound } from 'next/navigation';
import { MessageCircle } from 'lucide-react';
import { guestApi } from '@/lib/api';
import LiveMessages from './live-messages';

export default async function MessagesPage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  let data;
  try {
    data = await guestApi.getMessages(token);
  } catch {
    notFound();
  }

  return (
    <div className="min-h-screen bg-[--color-udo-cream] px-4 py-8">
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <MessageCircle size={24} className="text-[--color-udo-pink]" />
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700]">Updates</h1>
        <p className="text-sm text-[--color-udo-grey-500] mt-1">Messages from the couple</p>
      </div>

      {/* LiveMessages subscribes to the public Reverb channel and prepends
          new announcements in real time without reloading the page. */}
      <LiveMessages
        weddingId={data.wedding_id}
        initialMessages={data.messages}
      />
    </div>
  );
}
