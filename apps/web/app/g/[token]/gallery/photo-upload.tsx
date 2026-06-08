'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Camera, CheckCircle, X, ImagePlus } from 'lucide-react';
import { guestApi } from '@/lib/api';

interface Props {
  token: string;
}

type Stage = 'idle' | 'preview' | 'uploading' | 'done' | 'error';

export default function PhotoUpload({ token }: Props) {
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);

  const [stage, setStage] = useState<Stage>('idle');
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [caption, setCaption] = useState('');
  const [error, setError] = useState<string | null>(null);

  function pickFile() {
    inputRef.current?.click();
  }

  function onFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const selected = e.target.files?.[0];
    if (!selected) return;

    if (!selected.type.startsWith('image/')) {
      setError('Please select an image file.');
      return;
    }
    if (selected.size > 10 * 1024 * 1024) {
      setError('Image must be under 10 MB.');
      return;
    }

    setFile(selected);
    setPreview(URL.createObjectURL(selected));
    setCaption('');
    setError(null);
    setStage('preview');
    // Reset input so the same file can be reselected after cancel
    e.target.value = '';
  }

  function cancel() {
    if (preview) URL.revokeObjectURL(preview);
    setFile(null);
    setPreview(null);
    setCaption('');
    setError(null);
    setStage('idle');
  }

  async function submit() {
    if (!file) return;
    setStage('uploading');
    setError(null);
    try {
      await guestApi.uploadPhoto(token, file, caption);
      if (preview) URL.revokeObjectURL(preview);
      setStage('done');
      // Reload the server component so the new photo appears
      router.refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Upload failed. Please try again.');
      setStage('preview');
    }
  }

  // ── Done state ──────────────────────────────────────────────────────────────

  if (stage === 'done') {
    return (
      <div className="mx-1 rounded-2xl p-6 text-center bg-[--color-udo-teal]/5 border border-[--color-udo-teal]/20">
        <CheckCircle size={28} className="text-[--color-udo-teal] mx-auto mb-2" />
        <p className="text-sm font-semibold text-[--color-udo-grey-700]">Photo shared!</p>
        <p className="text-xs text-[--color-udo-grey-400] mt-0.5">
          Your memory has been added to the gallery.
        </p>
        <button
          onClick={() => setStage('idle')}
          className="mt-3 text-xs font-semibold text-[--color-udo-pink] underline underline-offset-2"
        >
          Share another
        </button>
      </div>
    );
  }

  // ── Preview / upload state ───────────────────────────────────────────────────

  if (stage === 'preview' || stage === 'uploading') {
    const isUploading = stage === 'uploading';
    return (
      <div className="mx-1 rounded-2xl overflow-hidden border border-[--color-udo-grey-200] bg-white shadow-sm">
        {/* Image preview */}
        <div className="relative aspect-video bg-[--color-udo-grey-100]">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={preview!}
            alt="Preview"
            className="w-full h-full object-cover"
          />
          {!isUploading && (
            <button
              onClick={cancel}
              className="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/50 flex items-center justify-center"
              aria-label="Remove"
            >
              <X size={14} className="text-white" />
            </button>
          )}
          {isUploading && (
            <div className="absolute inset-0 bg-black/30 flex items-center justify-center">
              <div className="w-8 h-8 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            </div>
          )}
        </div>

        {/* Caption + submit */}
        <div className="p-4 space-y-3">
          <input
            type="text"
            value={caption}
            onChange={(e) => setCaption(e.target.value)}
            placeholder="Add a caption (optional)"
            maxLength={200}
            disabled={isUploading}
            className="w-full px-3 py-2.5 rounded-xl border border-[--color-udo-grey-200] bg-[--color-udo-grey-100] text-sm text-[--color-udo-grey-700] placeholder:text-[--color-udo-grey-400] focus:outline-none focus:ring-2 focus:ring-[--color-udo-pink]/30 disabled:opacity-50"
          />

          {error && (
            <p className="text-xs text-red-500">{error}</p>
          )}

          <div className="flex gap-2">
            <button
              onClick={cancel}
              disabled={isUploading}
              className="flex-1 py-2.5 rounded-xl border border-[--color-udo-grey-200] text-sm font-semibold text-[--color-udo-grey-600] disabled:opacity-40"
            >
              Cancel
            </button>
            <button
              onClick={submit}
              disabled={isUploading}
              className="flex-1 py-2.5 rounded-xl text-sm font-semibold text-white disabled:opacity-60 transition-opacity"
              style={{ background: 'linear-gradient(135deg, #FF4D8C 0%, #D4006A 100%)' }}
            >
              {isUploading ? 'Sharing…' : 'Share photo'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ── Idle state ───────────────────────────────────────────────────────────────

  return (
    <>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="sr-only"
        onChange={onFileChange}
        aria-hidden="true"
      />
      <div className="mx-1">
        {error && (
          <p className="text-xs text-red-500 mb-2 text-center">{error}</p>
        )}
        <button
          onClick={pickFile}
          className="w-full border-2 border-dashed border-[--color-udo-pink]/30 rounded-2xl p-6 text-center hover:border-[--color-udo-pink]/60 hover:bg-[--color-udo-pink]/5 transition-colors group"
        >
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-[--color-udo-pink]/10 mb-3 group-hover:bg-[--color-udo-pink]/15 transition-colors">
            <ImagePlus size={20} className="text-[--color-udo-pink]" />
          </div>
          <p className="text-sm font-semibold text-[--color-udo-grey-700]">Share your photos</p>
          <p className="text-xs text-[--color-udo-grey-400] mt-1">
            Tap to pick a photo from your camera roll
          </p>
        </button>
      </div>
    </>
  );
}
