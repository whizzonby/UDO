import { notFound } from 'next/navigation';
import { Image as ImageIcon, Star } from 'lucide-react';
import { guestApi } from '@/lib/api';
import { formatDate } from '@/lib/utils';
import PhotoUpload from './photo-upload';

export default async function GalleryPage({
  params,
}: {
  params: Promise<{ token: string }>;
}) {
  const { token } = await params;

  let data;
  try {
    data = await guestApi.getGallery(token);
  } catch {
    notFound();
  }

  if (!data.visible) {
    return (
      <div className="min-h-screen bg-[--color-udo-cream] flex items-center justify-center px-4">
        <div className="text-center">
          <ImageIcon size={48} className="text-[--color-udo-grey-300] mx-auto mb-4" />
          <p className="text-[--color-udo-grey-500] text-sm">Gallery coming soon</p>
        </div>
      </div>
    );
  }

  const featured = data.items.filter((i) => i.is_featured);
  const rest = data.items.filter((i) => !i.is_featured);

  return (
    <div className="min-h-screen bg-[--color-udo-cream] pb-6">
      {/* Header */}
      <div className="px-4 py-8 text-center">
        <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-[--color-udo-pink]/10 mb-4">
          <ImageIcon size={24} className="text-[--color-udo-pink]" />
        </div>
        <h1 className="font-display text-3xl font-bold text-[--color-udo-grey-700]">Gallery</h1>
        <p className="text-sm text-[--color-udo-grey-500] mt-1">{data.items.length} memories</p>
      </div>

      {data.items.length === 0 ? (
        <div className="px-3 py-4 space-y-4">
          <div className="text-center py-8">
            <p className="text-[--color-udo-grey-400] text-sm">No photos yet — be the first!</p>
          </div>
          <PhotoUpload token={token} />
        </div>
      ) : (
        <div className="px-3 space-y-6">
          {/* Featured */}
          {featured.length > 0 && (
            <section>
              <div className="flex items-center gap-2 px-1 mb-3">
                <Star size={14} className="text-amber-400 fill-amber-400" />
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider">
                  Featured
                </p>
              </div>
              <div className="space-y-3">
                {featured.map((photo) => (
                  <div key={photo.id} className="rounded-2xl overflow-hidden bg-[--color-udo-grey-100] relative">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={photo.image_url}
                      alt={photo.caption ?? 'Wedding photo'}
                      className="w-full object-cover"
                      style={{ maxHeight: '70vw' }}
                    />
                    {(photo.caption || photo.uploaded_by) && (
                      <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent px-4 py-3">
                        {photo.caption && (
                          <p className="text-white text-sm font-medium leading-snug">{photo.caption}</p>
                        )}
                        {photo.uploaded_by && (
                          <p className="text-white/70 text-xs mt-0.5">📷 {photo.uploaded_by}</p>
                        )}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Grid */}
          {rest.length > 0 && (
            <section>
              {featured.length > 0 && (
                <p className="text-xs font-semibold text-[--color-udo-grey-500] uppercase tracking-wider px-1 mb-3">
                  All photos
                </p>
              )}
              <div className="grid grid-cols-3 gap-1">
                {rest.map((photo) => (
                  <div key={photo.id} className="aspect-square bg-[--color-udo-grey-100] rounded-lg overflow-hidden relative">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={photo.image_url}
                      alt={photo.caption ?? 'Wedding photo'}
                      className="w-full h-full object-cover"
                    />
                    {photo.uploaded_by && (
                      <div className="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent flex items-end p-1.5">
                        <span className="text-white text-[9px] font-medium truncate leading-none">
                          {photo.uploaded_by}
                        </span>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Guest photo upload */}
          <PhotoUpload token={token} />
        </div>
      )}
    </div>
  );
}
