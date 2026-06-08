import { notFound } from 'next/navigation';
import { Gift, ExternalLink, Heart } from 'lucide-react';
import { guestApi } from '@/lib/api';
import { formatCurrency } from '@/lib/utils';
import { ContributeForm } from './contribute-form';

export default async function RegistryPage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  let data;
  try {
    data = await guestApi.getRegistry(token);
  } catch {
    notFound();
  }

  if (!data.visible) {
    return (
      <div className="min-h-screen bg-[--color-udo-cream] flex items-center justify-center px-4">
        <div className="text-center">
          <Gift size={48} className="text-[--color-udo-grey-300] mx-auto mb-4" />
          <p className="text-[--color-udo-grey-500] text-sm">Registry coming soon</p>
        </div>
      </div>
    );
  }

  const unclaimed = data.items.filter((i) => !i.is_claimed);
  const claimed = data.items.filter((i) => i.is_claimed);

  return (
    <div className="min-h-screen bg-[--color-udo-cream] px-4 py-8">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <Gift size={24} className="text-[--color-udo-pink]" />
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700]">Registry</h1>
        <p className="text-sm text-[--color-udo-grey-500] mt-1">
          {unclaimed.length} gift{unclaimed.length !== 1 ? 's' : ''} available
        </p>
      </div>

      <div className="max-w-md mx-auto space-y-6">
        {/* Cash fund */}
        {data.fund && (
          <div className="bg-gradient-to-br from-[--color-udo-pink] to-[--color-udo-pink-dark] rounded-2xl p-6 text-white">
            <div className="flex items-start gap-3 mb-3">
              <Heart size={22} className="mt-0.5 fill-white/30 stroke-white shrink-0" />
              <div>
                <h2 className="font-semibold text-lg leading-tight">{data.fund.title}</h2>
                {data.fund.description && (
                  <p className="text-white/80 text-sm mt-1 leading-relaxed">{data.fund.description}</p>
                )}
              </div>
            </div>

            {/* Progress bar */}
            {data.fund.target_amount && data.fund.target_amount > 0 && (
              <div className="mb-4">
                <div className="flex justify-between items-baseline mb-1.5">
                  <span className="text-white/90 text-sm font-semibold">
                    {formatCurrency(data.fund.raised_amount)} raised
                  </span>
                  <span className="text-white/60 text-xs">
                    of {formatCurrency(data.fund.target_amount)}
                  </span>
                </div>
                <div className="h-1.5 bg-white/20 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-white rounded-full transition-all"
                    style={{
                      width: `${Math.min(100, (data.fund.raised_amount / data.fund.target_amount) * 100).toFixed(1)}%`,
                    }}
                  />
                </div>
              </div>
            )}

            <ContributeForm token={token} fund={data.fund} />
          </div>
        )}

        {/* Gifts list */}
        {data.items.length === 0 ? (
          <div className="text-center py-8">
            <p className="text-[--color-udo-grey-400] text-sm">No gifts listed yet</p>
          </div>
        ) : (
          <>
            {unclaimed.length > 0 && (
              <section>
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-3">
                  Available gifts
                </p>
                <div className="space-y-3">
                  {unclaimed.map((item) => (
                    <div
                      key={item.id}
                      className="bg-white rounded-2xl p-4 border border-[--color-udo-grey-200] flex gap-4"
                    >
                      {item.image_url && (
                        <div className="w-16 h-16 rounded-xl overflow-hidden shrink-0 bg-[--color-udo-grey-100]">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={item.image_url}
                            alt={item.title}
                            className="w-full h-full object-cover"
                          />
                        </div>
                      )}
                      <div className="flex-1 min-w-0">
                        <p className="font-semibold text-sm text-[--color-udo-grey-700] leading-snug">
                          {item.title}
                        </p>
                        {item.description && (
                          <p className="text-xs text-[--color-udo-grey-400] mt-0.5 line-clamp-2">
                            {item.description}
                          </p>
                        )}
                        <div className="flex items-center gap-3 mt-2">
                          {item.price && (
                            <span className="text-xs font-semibold text-[--color-udo-grey-600]">
                              {formatCurrency(item.price)}
                            </span>
                          )}
                          {item.category && (
                            <span className="text-xs text-[--color-udo-grey-400] bg-[--color-udo-grey-100] px-2 py-0.5 rounded-full">
                              {item.category}
                            </span>
                          )}
                        </div>
                        {item.url && (
                          <a
                            href={item.url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center gap-1 text-xs text-[--color-udo-pink] font-medium mt-2 hover:underline"
                          >
                            View item <ExternalLink size={10} />
                          </a>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}

            {claimed.length > 0 && (
              <section>
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider mb-3">
                  Already claimed ({claimed.length})
                </p>
                <div className="space-y-2">
                  {claimed.map((item) => (
                    <div
                      key={item.id}
                      className="bg-white/60 rounded-xl px-4 py-3 border border-[--color-udo-grey-200] flex items-center gap-3 opacity-60"
                    >
                      <Gift size={14} className="text-[--color-udo-teal] shrink-0" />
                      <p className="text-sm text-[--color-udo-grey-500] line-through flex-1 truncate">
                        {item.title}
                      </p>
                      <span className="text-xs text-[--color-udo-teal] font-medium shrink-0">Claimed</span>
                    </div>
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </div>
  );
}
