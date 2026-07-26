'use client';

import { useEffect, useRef, useState } from 'react';
import { Upload } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { getToken } from '@/lib/auth';

type Asset = {
  id: number;
  type: string;
  url: string;
  thumbnail_url: string | null;
  approved: boolean;
};

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

function resolveUrl(url: string | null): string {
  if (!url) return '';
  return url.startsWith('http') ? url : `${API_BASE.replace(/\/api$/, '')}${url}`;
}

export default function DashboardGalleryPage() {
  const { token } = useAuth();
  const [assets, setAssets] = useState<Asset[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const fileInput = useRef<HTMLInputElement>(null);

  const load = async () => {
    if (!token) return;
    try {
      const res = await fetch(`${API_BASE}/gallery`, { headers: { Authorization: `Bearer ${token}` } });
      const data = await res.json();
      setAssets(data.data ?? []);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, [token]);

  const upload = async (file: File) => {
    const t = getToken();
    if (!t) return;
    setUploading(true);
    try {
      const form = new FormData();
      form.append('file', file);
      form.append('album', 'moments');
      const res = await fetch(`${API_BASE}/gallery`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${t}` },
        body: form,
      });
      const data = await res.json();
      if (data.data) setAssets((prev) => [data.data, ...prev]);
    } finally {
      setUploading(false);
    }
  };

  if (loading) {
    return <div className="w-8 h-8 border-2 border-[#285301] border-t-transparent rounded-full animate-spin" />;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold text-gray-800">Gallery</h1>
        <button
          onClick={() => fileInput.current?.click()}
          disabled={uploading}
          className="flex items-center gap-2 px-4 py-2 rounded-xl bg-[#285301] text-white text-sm disabled:opacity-60"
        >
          <Upload size={14} /> {uploading ? 'Uploading...' : 'Upload'}
        </button>
        <input
          ref={fileInput}
          type="file"
          accept="image/*,video/*"
          className="hidden"
          onChange={(e) => e.target.files?.[0] && upload(e.target.files[0])}
        />
      </div>

      {assets.length === 0 ? (
        <p className="text-sm text-gray-400 py-16 text-center">No photos yet — full editing happens in the app.</p>
      ) : (
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-2">
          {assets.map((asset) => (
            <div key={asset.id} className="aspect-square rounded-xl overflow-hidden bg-gray-100">
              {asset.type === 'photo' ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={resolveUrl(asset.thumbnail_url ?? asset.url)} alt="" className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-xs text-gray-400">{asset.type}</div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
