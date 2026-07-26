'use client';

import { useEffect, useState } from 'react';
import { Camera, Heart } from 'lucide-react';
import VoiceRecorder from './VoiceRecorder';

type UploadLinkData = {
  couple_name_primary: string;
  couple_name_secondary: string | null;
  venue: string | null;
  uploads_open: boolean;
};

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

export default function GalleryUploadPortal({ token }: { token: string }) {
  const [data, setData] = useState<UploadLinkData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [photoFile, setPhotoFile] = useState<File | null>(null);
  const [voiceFile, setVoiceFile] = useState<File | null>(null);
  const [caption, setCaption] = useState('');
  const [uploaderName, setUploaderName] = useState('');
  const [saving, setSaving] = useState(false);
  const [uploaded, setUploaded] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);

  useEffect(() => {
    fetch(`${API_BASE}/upload/${token}`)
      .then(r => {
        if (!r.ok) throw new Error('This upload link is invalid or has expired.');
        return r.json();
      })
      .then(res => setData(res.data))
      .catch(e => setError(e instanceof Error ? e.message : 'This upload link is invalid or has expired.'))
      .finally(() => setLoading(false));
  }, [token]);

  const upload = async () => {
    const fileToSend = photoFile ?? voiceFile;
    if (!fileToSend) return;
    setSaving(true);
    setUploadError(null);
    try {
      const form = new FormData();
      form.append('file', fileToSend);
      if (caption.trim()) form.append('caption', caption.trim());
      if (uploaderName.trim()) form.append('uploaded_by_name', uploaderName.trim());
      const res = await fetch(`${API_BASE}/upload/${token}/gallery`, { method: 'POST', body: form });
      if (!res.ok) throw new Error('Could not upload this. Please try again.');
      setPhotoFile(null);
      setVoiceFile(null);
      setCaption('');
      setUploaded(true);
    } catch (e) {
      setUploadError(e instanceof Error ? e.message : 'Could not upload this. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb]">
        <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb] p-6">
        <div className="text-center">
          <Heart className="mx-auto mb-4 text-[#d45d78]" size={48} />
          <h1 className="text-xl font-semibold text-gray-800 mb-2">Link Not Found</h1>
          <p className="text-gray-500">{error ?? 'This upload link is invalid or has expired.'}</p>
        </div>
      </div>
    );
  }

  const coupleName = data.couple_name_secondary
    ? `${data.couple_name_primary} & ${data.couple_name_secondary}`
    : data.couple_name_primary;

  if (uploaded) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-[#f8edeb] p-6 text-center">
        <div className="w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6 bg-[#285301]">
          <Heart className="text-white" size={28} fill="white" />
        </div>
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Thank you!</h1>
        <p className="text-gray-500 mb-6">Your message has been sent to {coupleName} for review.</p>
        <button
          onClick={() => setUploaded(false)}
          className="py-3 px-6 rounded-xl text-sm font-semibold text-white bg-[#285301]"
        >
          Share another
        </button>
      </div>
    );
  }

  if (!data.uploads_open) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f8edeb] p-6">
        <div className="text-center max-w-sm">
          <Heart className="mx-auto mb-4 text-[#d45d78]" size={48} />
          <h1 className="text-xl font-semibold text-gray-800 mb-2">Uploads Not Open Yet</h1>
          <p className="text-gray-500">
            {coupleName} hasn&apos;t opened photo uploads for this wedding yet. Please check back later.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#f8edeb] pb-8">
      <div className="bg-white px-6 pt-12 pb-8 text-center border-b border-gray-100">
        <div className="w-12 h-12 rounded-full bg-[#f194b2] flex items-center justify-center mx-auto mb-4">
          <Camera className="text-white" size={22} />
        </div>
        <p className="text-sm text-[#d45d78] font-medium mb-1">Share a moment from</p>
        <h1 className="text-2xl font-bold text-[#285301]">{coupleName}&apos;s Wedding</h1>
        {data.venue && <p className="text-gray-500 mt-1 text-sm">{data.venue}</p>}
      </div>

      <section className="bg-white mx-4 mt-4 rounded-2xl p-5 shadow-sm">
        <h2 className="text-base font-semibold text-gray-800 mb-4">Share a photo, video, or voice message</h2>
        <div className="space-y-3">
          <input
            type="file"
            accept="image/*,video/*"
            onChange={event => { setPhotoFile(event.target.files?.[0] ?? null); setVoiceFile(null); }}
            className="block w-full text-sm text-gray-600"
          />
          <div className="flex items-center gap-2 text-xs text-gray-400">
            <div className="flex-1 border-t border-gray-100" />
            or
            <div className="flex-1 border-t border-gray-100" />
          </div>
          <VoiceRecorder onRecorded={file => { setVoiceFile(file); if (file) setPhotoFile(null); }} />
          <input
            value={uploaderName}
            onChange={event => setUploaderName(event.target.value)}
            placeholder="Your name (optional)"
            className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
          />
          <input
            value={caption}
            onChange={event => setCaption(event.target.value)}
            placeholder="Caption (optional)"
            className="w-full border border-gray-200 rounded-xl px-3 py-2 text-sm"
          />
          <button
            disabled={(!photoFile && !voiceFile) || saving}
            onClick={upload}
            className="w-full py-3 rounded-xl text-sm font-semibold text-white disabled:opacity-50 bg-[#285301]"
          >
            {saving ? 'Uploading...' : 'Upload for review'}
          </button>
          {uploadError && <p className="text-xs text-red-500">{uploadError}</p>}
          <p className="text-xs text-gray-400">
            Your upload will be reviewed by the couple before it appears in their gallery.
          </p>
        </div>
      </section>
    </div>
  );
}
