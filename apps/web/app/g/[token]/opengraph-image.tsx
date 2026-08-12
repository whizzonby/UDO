import { ImageResponse } from 'next/og';
import { readFile } from 'node:fs/promises';
import path from 'node:path';

export const alt = "You're Invited";
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

// Every string rendered onto the card must be covered by this font. Satori
// falls back to its own bundled default font for any glyph this doesn't
// cover, and that fallback's path resolution breaks on Windows dev machines
// with a space in the project path (e.g. "E:\UDO APP") — keeping copy to
// plain ASCII and always supplying this font avoids that fallback entirely,
// on every platform.
async function loadInviteFont(text: string) {
  try {
    const cssUrl = `https://fonts.googleapis.com/css2?family=DM+Serif+Display&text=${encodeURIComponent(text)}`;
    const css = await (await fetch(cssUrl)).text();
    const match = css.match(/src: url\(([^)]+)\) format\('(opentype|truetype)'\)/);
    if (!match) return null;
    const fontRes = await fetch(match[1]);
    if (!fontRes.ok) return null;
    return await fontRes.arrayBuffer();
  } catch {
    return null;
  }
}

export default async function Image({ params }: { params: { token: string } }) {
  let couple = 'Our Wedding';
  let dateLabel = '';
  let locationLabel = '';

  try {
    const res = await fetch(`${API_BASE}/g/${params.token}`, { next: { revalidate: 3600 } });
    if (res.ok) {
      const data = await res.json();
      const wedding = data.wedding;
      couple = wedding.couple_name_secondary
        ? `${wedding.couple_name_primary} & ${wedding.couple_name_secondary}`
        : wedding.couple_name_primary;
      dateLabel = wedding.event_date
        ? new Date(`${wedding.event_date}T00:00:00`).toLocaleDateString('en-US', {
            weekday: 'long',
            month: 'long',
            day: 'numeric',
            year: 'numeric',
          })
        : '';
      locationLabel = [wedding.city, wedding.country].filter(Boolean).join(', ');
    }
  } catch {
    // Link-preview crawlers can't fail — fall back to a generic card.
  }

  const flowerBuffer = await readFile(path.join(process.cwd(), 'public/guest-portal/rose.jpeg'));
  const flowerDataUrl = `data:image/jpeg;base64,${flowerBuffer.toString('base64')}`;

  const cardText = `${couple.toUpperCase()} You're Invited ${dateLabel} ${locationLabel}`;
  const fontData = await loadInviteFont(cardText);
  const fontFamily = fontData ? 'DM Serif Display' : undefined;

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          position: 'relative',
          backgroundColor: '#fbf7f4',
          fontFamily,
        }}
      >
        <img
          src={flowerDataUrl}
          alt=""
          width={1200}
          height={630}
          style={{ position: 'absolute', top: 0, left: 0, objectFit: 'cover' }}
        />
        <div
          style={{
            position: 'absolute',
            inset: 0,
            display: 'flex',
            backgroundImage:
              'linear-gradient(120deg, rgba(255,255,255,.97) 0%, rgba(255,255,255,.93) 45%, rgba(255,255,255,.35) 100%)',
          }}
        />
        <div
          style={{
            position: 'relative',
            width: '100%',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '60px',
            textAlign: 'center',
          }}
        >
          <div
            style={{
              display: 'flex',
              fontSize: 22,
              letterSpacing: 6,
              color: '#9b6a75',
              textTransform: 'uppercase',
            }}
          >
            {couple}
          </div>
          <div style={{ display: 'flex', fontSize: 88, color: '#2d2729', marginTop: 18 }}>
            You&apos;re Invited
          </div>
          {/* A plain CSS divider instead of a heart glyph — keeps every
              character on the card covered by the one loaded font. */}
          <div
            style={{
              display: 'flex',
              width: 64,
              height: 3,
              marginTop: 22,
              borderRadius: 2,
              backgroundColor: '#d9b9bd',
            }}
          />
          {dateLabel ? (
            <div style={{ display: 'flex', fontSize: 24, color: '#4f4648', marginTop: 22 }}>
              {dateLabel}
            </div>
          ) : null}
          {locationLabel ? (
            <div style={{ display: 'flex', fontSize: 20, color: '#6f6768', marginTop: 6 }}>
              {locationLabel}
            </div>
          ) : null}
        </div>
      </div>
    ),
    {
      ...size,
      fonts: fontData ? [{ name: 'DM Serif Display', data: fontData, style: 'normal', weight: 400 }] : undefined,
    },
  );
}
