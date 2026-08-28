'use client';

import { useEffect } from 'react';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

function clickId(): string {
  try {
    const existing = sessionStorage.getItem('udo_click_id');
    if (existing) return existing;
    const id =
      (crypto.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2)}`).replace(/-/g, '').slice(0, 32);
    sessionStorage.setItem('udo_click_id', id);
    return id;
  } catch {
    return `${Date.now()}${Math.random().toString(36).slice(2, 10)}`;
  }
}

/**
 * Fires a fire-and-forget beacon to the API whenever a visitor taps a link to
 * the Play Store / App Store, so app-link clicks show up in the admin panel.
 * Uses form-encoded sendBeacon (a CORS-safelisted content type) so there's no
 * preflight and it survives the page navigating away.
 */
export function StoreClickTracker() {
  useEffect(() => {
    function onClick(e: MouseEvent) {
      const target = e.target as HTMLElement | null;
      const anchor = target?.closest?.('a') as HTMLAnchorElement | null;
      if (!anchor?.href) return;

      const isPlay = anchor.href.includes('play.google.com');
      const isAppStore = anchor.href.includes('apps.apple.com');
      if (!isPlay && !isAppStore) return;

      try {
        const params = new URLSearchParams(window.location.search);
        const body = new URLSearchParams({
          platform: isPlay ? 'android' : 'ios',
          source_path: window.location.pathname,
          click_id: clickId(),
        });
        const placement = anchor.getAttribute('data-store-link');
        if (placement) body.set('link_location', placement);
        if (document.referrer) body.set('referrer', document.referrer.slice(0, 512));
        for (const key of ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'utm_term']) {
          const v = params.get(key);
          if (v) body.set(key, v);
        }

        navigator.sendBeacon(`${API_BASE}/track/store-click`, body);
      } catch {
        // never block the navigation
      }
    }

    document.addEventListener('click', onClick, { capture: true });
    return () => document.removeEventListener('click', onClick, { capture: true });
  }, []);

  return null;
}
