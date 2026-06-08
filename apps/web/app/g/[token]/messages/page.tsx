import { notFound } from 'next/navigation';
import { MessageCircle } from 'lucide-react';
import { guestApi } from '@/lib/api';
import { formatDate } from '@/lib/utils';

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
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <MessageCircle size={24} className="text-[--color-udo-pink]" />
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700]">Updates</h1>
        <p className="text-sm text-[--color-udo-grey-500] mt-1">Messages from the couple</p>
      </div>

      {data.messages.length === 0 ? (
        <div className="text-center py-16">
          <MessageCircle size={48} className="text-[--color-udo-grey-300] mx-auto mb-4" />
          <p className="text-[--color-udo-grey-500] text-sm">No messages yet</p>
          <p className="text-[--color-udo-grey-400] text-xs mt-1">
            Any updates from the couple will appear here
          </p>
        </div>
      ) : (
        <div className="max-w-md mx-auto space-y-4">
          {data.messages.map((msg) => (
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
      )}
    </div>
  );
}
