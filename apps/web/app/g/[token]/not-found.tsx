import Link from 'next/link';

export default function GuestNotFound() {
  return (
    <div className="min-h-screen bg-[--color-udo-cream] flex flex-col items-center justify-center px-6 text-center">
      <div className="text-6xl mb-6">💌</div>
      <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700] mb-3">
        Link not found
      </h1>
      <p className="text-[--color-udo-grey-500] text-sm max-w-xs leading-relaxed">
        This invitation link may have expired or been updated. Check the original message for the latest link.
      </p>
    </div>
  );
}
