'use client';

import { QRCodeSVG } from 'qrcode.react';
import { Smartphone } from 'lucide-react';

const APP_STORE_URL = process.env.NEXT_PUBLIC_APP_STORE_URL || null;
const PLAY_STORE_URL = process.env.NEXT_PUBLIC_PLAY_STORE_URL || null;

export function DownloadAppCard() {
  const qrTarget = APP_STORE_URL || PLAY_STORE_URL;

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-6 flex flex-col sm:flex-row items-center gap-6">
      <div className="flex-1">
        <div className="flex items-center gap-2 mb-2">
          <Smartphone className="text-[#285301]" size={20} />
          <h3 className="text-base font-semibold text-gray-800">Everything happens in the app</h3>
        </div>
        <p className="text-sm text-gray-500 leading-relaxed mb-4">
          Guests, planning, gallery, and your wedding day all live in the Udo mobile app. This
          dashboard is just for your account and billing.
        </p>
        <div className="flex flex-wrap gap-3">
          <a
            href={APP_STORE_URL ?? undefined}
            target="_blank"
            rel="noreferrer"
            aria-disabled={!APP_STORE_URL}
            className={`px-4 py-2 rounded-xl text-sm font-medium border ${
              APP_STORE_URL
                ? 'bg-black text-white border-black'
                : 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed'
            }`}
          >
            {APP_STORE_URL ? 'Download on the App Store' : 'App Store — coming soon'}
          </a>
          <a
            href={PLAY_STORE_URL ?? undefined}
            target="_blank"
            rel="noreferrer"
            aria-disabled={!PLAY_STORE_URL}
            className={`px-4 py-2 rounded-xl text-sm font-medium border ${
              PLAY_STORE_URL
                ? 'bg-black text-white border-black'
                : 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed'
            }`}
          >
            {PLAY_STORE_URL ? 'Get it on Google Play' : 'Google Play — coming soon'}
          </a>
        </div>
      </div>
      {qrTarget && (
        <div className="flex flex-col items-center gap-2">
          <div className="rounded-xl border border-gray-200 p-3 bg-white">
            <QRCodeSVG value={qrTarget} size={104} />
          </div>
          <span className="text-xs text-gray-400">Scan to download</span>
        </div>
      )}
    </div>
  );
}
