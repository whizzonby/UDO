import { notFound } from 'next/navigation';
import { guestApi } from '@/lib/api';
import { RsvpForm } from './rsvp-form';

export default async function RsvpPage({
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

  return (
    <div className="min-h-screen bg-[--color-udo-cream] px-4 py-8">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#FF4D8C" strokeWidth="1.8">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700] mb-1">Your RSVP</h1>
        <p className="text-sm text-[--color-udo-grey-500]">
          {data.wedding.partner_one_name}
          {data.wedding.partner_two_name && ` & ${data.wedding.partner_two_name}`}
        </p>
      </div>

      <RsvpForm
        token={token}
        guest={data.guest}
      />
    </div>
  );
}
