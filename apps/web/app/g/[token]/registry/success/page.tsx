import Link from 'next/link';
import { Heart, ArrowLeft } from 'lucide-react';

export default async function ContributeSuccessPage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  return (
    <div className="min-h-screen bg-[--color-udo-cream] flex items-center justify-center px-4">
      <div className="max-w-sm w-full text-center">
        {/* Icon */}
        <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-[--color-udo-pink] to-[--color-udo-pink-dark] mb-6 shadow-lg">
          <Heart size={36} className="fill-white stroke-white" />
        </div>

        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700] mb-3">
          Thank you!
        </h1>
        <p className="text-[--color-udo-grey-500] text-sm leading-relaxed mb-8">
          Your contribution has been received. The couple will be so touched by your generosity.
        </p>

        <Link
          href={`/g/${token}/registry`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[--color-udo-pink] hover:underline"
        >
          <ArrowLeft size={15} />
          Back to registry
        </Link>
      </div>
    </div>
  );
}
