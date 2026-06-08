const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:8000/api';

export type RsvpStatus = 'pending' | 'attending' | 'declined' | 'maybe';

export interface GuestData {
  id: string;
  first_name: string;
  full_name: string;
  rsvp_status: RsvpStatus;
  plus_one_allowed: boolean;
  plus_one_name: string | null;
  dietary_requirements: string | null;
  needs_transport: boolean;
  needs_accommodation: boolean;
  checked_in_at: string | null;
}

export interface WeddingData {
  partner_one_name: string;
  partner_two_name: string | null;
  wedding_date: string | null;
  venue_name: string | null;
  venue_address: string | null;
  venue_city: string | null;
  cover_photo_url: string | null;
  status: 'planning' | 'live' | 'completed';
  timezone: string;
  is_live: boolean;
}

export interface ExperienceConfig {
  is_published: boolean;
  welcome_message: string | null;
  show_schedule: boolean;
  show_venue: boolean;
  show_registry: boolean;
  show_gallery: boolean;
  show_messages: boolean;
  theme_color: string | null;
}

export interface TimelineEvent {
  id: string;
  title: string;
  description: string | null;
  event_date: string | null;
  start_time: string | null;
  end_time: string | null;
  location: string | null;
  type: string | null;
}

export interface TableAssignmentData {
  name: string;
  shape: string;
  section: string | null;
}

export interface GuestPortalData {
  guest: GuestData;
  wedding: WeddingData;
  experience: ExperienceConfig | null;
  day_schedule: TimelineEvent[];
  table: TableAssignmentData | null;
}

export interface RegistryItem {
  id: string;
  title: string;
  description: string | null;
  price: number | null;
  url: string | null;
  image_url: string | null;
  category: string | null;
  is_claimed: boolean;
  claimed_by_name: string | null;
}

export interface CashFund {
  id: string;
  title: string;
  description: string | null;
  target_amount: number | null;
  raised_amount: number;
  share_token: string;
}

export interface RegistryData {
  visible: boolean;
  items: RegistryItem[];
  fund: CashFund | null;
}

export interface GalleryPhoto {
  id: string;
  image_url: string;
  caption: string | null;
  uploaded_by: string | null;
  is_featured: boolean;
  created_at: string | null;
}

export interface Message {
  id: string;
  subject: string | null;
  body: string;
  sent_at: string | null;
}

async function guestFetch<T>(token: string, path: string, init?: RequestInit): Promise<T> {
  const url = `${API_URL}/guest-portal/${token}${path}`;
  const res = await fetch(url, {
    ...init,
    headers: { 'Content-Type': 'application/json', Accept: 'application/json', ...init?.headers },
  });
  if (!res.ok) throw new Error(`API error ${res.status}`);
  return res.json() as Promise<T>;
}

export const guestApi = {
  getPortal: (token: string) =>
    guestFetch<GuestPortalData>(token, '/'),

  rsvp: (token: string, data: {
    status: RsvpStatus;
    dietary_requirements?: string;
    plus_one_attending?: boolean;
    plus_one_name?: string;
    message_to_couple?: string;
  }) =>
    guestFetch<{ success: boolean; rsvp_status: string; message: string }>(token, '/rsvp', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  getSchedule: (token: string) =>
    guestFetch<{ wedding_date: string | null; timezone: string; events: TimelineEvent[] }>(
      token, '/schedule'
    ),

  getRegistry: (token: string) =>
    guestFetch<RegistryData>(token, '/registry'),

  getGallery: (token: string) =>
    guestFetch<{ visible: boolean; items: GalleryPhoto[] }>(token, '/gallery'),

  getMessages: (token: string) =>
    guestFetch<{ messages: Message[] }>(token, '/messages'),

  contribute: (token: string, data: { amount: number; name?: string; message?: string }) =>
    guestFetch<{ checkout_url: string }>(token, '/fund/contribute', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  uploadPhoto: async (token: string, image: File, caption?: string): Promise<GalleryPhoto> => {
    const form = new FormData();
    form.append('image', image);
    if (caption?.trim()) form.append('caption', caption.trim());
    const url = `${API_URL}/guest-portal/${token}/gallery`;
    const res = await fetch(url, {
      method: 'POST',
      // No Content-Type header — browser sets multipart boundary automatically
      headers: { Accept: 'application/json' },
      body: form,
    });
    if (!res.ok) {
      const data = await res.json().catch(() => ({}));
      throw new Error((data as { message?: string }).message ?? `Upload failed (${res.status})`);
    }
    const data = await res.json();
    return (data as { item: GalleryPhoto }).item;
  },
};
